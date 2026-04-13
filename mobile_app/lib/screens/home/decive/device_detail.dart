import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/api/health_service.dart';
import 'package:Care_AI/models/health_icon_mapper.dart';
import 'package:Care_AI/services/health_backend_sync.dart';
import 'package:Care_AI/services/health_connect_prefs.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String appName;
  final String deviceId;

  /// true = đang nằm trong tab Thiết bị (không push route riêng).
  final bool embeddedInTab;

  /// Gọi khi ngắt kết nối ở chế độ [embeddedInTab] để tab quay lại màn kết nối.
  final VoidCallback? onDisconnected;

  const DeviceDetailScreen({
    super.key,
    this.appName = "Huawei Health",
    this.deviceId = "DEVICE001",
    this.embeddedInTab = false,
    this.onDisconnected,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with WidgetsBindingObserver {
  static const _bg = Color(0xFFF6F6F6);
  // Trong app: polling 20s để ổn định, không quá 5s gây load quá mức.
  static const _pollInterval = Duration(seconds: 20);

  bool _loading = true;
  String? _error;
  List<_MetricViewItem> _metrics = [];
  Timer? _pollTimer;

  /// Health Connect đôi khi trả snapshot rỗng giữa các lần đọc — giữ giá trị đã đọc được.
  static int _lastGoodSteps = 0;
  static final Map<String, dynamic> _lastGoodSummary = {};

  static const _fallbackDefinitions = {
    'CS004': {'name': 'Số bước chân', 'unit': 'steps', 'category': 'activity'},
    'CS023': {'name': 'Quãng đường', 'unit': 'km', 'category': 'activity'},
    'CS005': {'name': 'Calo tiêu thụ', 'unit': 'kcal', 'category': 'activity'},
    'CS001': {'name': 'Nhịp tim', 'unit': 'bpm', 'category': 'health'},
    'CS003': {'name': 'Huyết áp', 'unit': 'mmHg', 'category': 'health'},
    'CS018': {'name': 'SpO2', 'unit': '%', 'category': 'health'},
    'CS006': {'name': 'Nhịp thở', 'unit': 'breaths/min', 'category': 'health'},
    'CS021': {'name': 'Nhiệt độ cơ thể', 'unit': '°C', 'category': 'health'},
    'CS037': {'name': 'Thời gian ngủ', 'unit': 'giờ', 'category': 'activity'},
    'CS007': {'name': 'Nhịp tim nghỉ', 'unit': 'bpm', 'category': 'health'},
    'CS008': {
      'name': 'Biến thiên nhịp tim (HRV)',
      'unit': 'ms',
      'category': 'health'
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load last synced values để delta sync hoạt động
    HealthBackendSync.loadLastSyncedValues();

    // Hiển thị ngay nếu có dữ liệu cache từ lần trước (giúp không bị loading lại)
    if (_lastGoodSteps > 0 || _lastGoodSummary.isNotEmpty) {
      _loading = false;
      _metrics = _buildMetricsList(
        steps: _effectiveStepsForDisplay(_lastGoodSteps, _lastGoodSummary),
        summary: _effectiveSummaryForDisplay(_lastGoodSummary),
        permissionOk: true,
        apiMetrics: null,
      );
    }

    _loadHealthData();
    _startPolling();
    // Đảm bảo lưu trạng thái đã kết nối (vào thẳng màn này lần sau khi còn quyền HC).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await HealthService.checkPermission();
      if (ok && mounted) {
        await HealthConnectPrefs.setLinked(widget.appName);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi quay lại app, luôn reload ngay lập tức.
      if (mounted) _loadHealthData(syncAndNotify: false);
      _startPolling();
    } else {
      _pollTimer?.cancel();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();

    // Chỉ poll nhẹ, 15-30s; nếu người dùng không thao tác vẫn cập nhật dần.
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (mounted) _loadHealthData(syncAndNotify: false);
    });
  }

  Future<void> _loadHealthData({bool syncAndNotify = false}) async {
    try {
      final permissionOk = await HealthService.checkPermission();
      if (permissionOk)
        _syncToBackendInBackground(showSuccessSnackBar: syncAndNotify);

      final steps = await HealthService.getSteps();
      final summary = await HealthService.getHealthSummary();
      _mergeHealthSnapshot(steps, summary);
      final displaySteps = _effectiveStepsForDisplay(steps, summary);
      final displaySummary = _effectiveSummaryForDisplay(summary);

      // Lấy TenChiSo, DonViDo từ LoaiChiSoSucKhoe qua API (fallback hardcode nếu chưa đăng nhập)
      final metricMap = <String, Map<String, String>>{};
      try {
        final list = await HealthApi.getMetrics();
        for (final m in list) {
          final id = (m['LoaiChiSo_ID'] ?? '').toString().trim();
          if (id.isEmpty) continue;
          metricMap[id] = {
            'name': (m['TenChiSo'] ?? '').toString(),
            'unit': (m['DonViDo'] ?? '').toString(),
            'category': (m['Category'] ?? 'health').toString(),
          };
        }
      } catch (_) {}

      final deduped = _buildMetricsList(
        steps: displaySteps,
        summary: displaySummary,
        permissionOk: permissionOk,
        apiMetrics: metricMap.isNotEmpty ? metricMap : null,
      );

      if (!mounted) return;
      setState(() {
        _metrics = deduped;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (_metrics.isEmpty && _loading) {
        setState(() {
          _error = context.tr.loadHealthError;
          _loading = false;
        });
      }
    }
  }

  List<_MetricViewItem> _buildMetricsList({
    required int steps,
    required Map<String, dynamic> summary,
    required bool permissionOk,
    Map<String, Map<String, String>>? apiMetrics,
  }) {
    String normalizeKey(String key) {
      return key.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '').trim();
    }

    final defsByHcKey = <String, Map<String, dynamic>>{};
    for (final e in HealthBackendSync.hcToLoaiChiSo.entries) {
      // Ưu tiên API, fallback về hardcode
      final info = apiMetrics?[e.value] ?? _fallbackDefinitions[e.value];
      if (info == null) continue;
      defsByHcKey[e.key] = {
        'hcKey': e.key,
        'name': info['name'] ?? e.key,
        'unit': info['unit'] ?? '',
        'category': info['category'] ?? 'health',
      };
    }

    // Thêm metric lạ từ summary nếu lâu lâu mới có (không có trong hcToLoaiChiSo)
    for (final key in summary.keys) {
      if (!defsByHcKey.containsKey(key)) {
        defsByHcKey[key] = {
          'hcKey': key,
          'name': key,
          'unit': '',
          'category': 'unknown',
        };
      }
    }

    final mapped = defsByHcKey.values.map<_MetricViewItem>((metric) {
      final name = metric['name'] as String;
      final unit = metric['unit'] as String;
      final category = metric['category'] as String;
      final hcKey = metric['hcKey'] as String;
      final iconData = getHealthIcon(name);
      final value = _resolveMetricValue(
        hcKey: hcKey,
        permissionOk: permissionOk,
        steps: steps,
        summary: summary,
      );

      return _MetricViewItem(
        name: name,
        unit: unit,
        value: value,
        category: category,
        icon: iconData.icon,
        color: iconData.color,
      );
    }).toList();

    final seenNames = <String>{};
    final deduped = <_MetricViewItem>[];
    for (final item in mapped) {
      final normalizedName = normalizeKey(item.name);
      if (seenNames.contains(normalizedName)) continue;
      seenNames.add(normalizedName);
      deduped.add(item);
    }

    deduped.sort((a, b) {
      final aHasData = a.value != '--';
      final bHasData = b.value != '--';
      if (aHasData != bHasData) return aHasData ? -1 : 1;
      final categoryCompare =
          a.category.toLowerCase().compareTo(b.category.toLowerCase());
      if (categoryCompare != 0) return categoryCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return deduped;
  }

  void _mergeHealthSnapshot(int steps, Map<String, dynamic> summary) {
    if (steps > 0) {
      // Chỉ cập nhật cache nếu có dữ liệu thực tế (> 0)
      // Nếu steps == 0 (do lỗi đọc hoặc chưa đi), giữ nguyên giá trị cũ để UI không bị "về 0" đột ngột.
      _lastGoodSteps = steps;
    }

    if (summary.isEmpty) return;
    for (final e in summary.entries) {
      if (_isMeaningfulHealthValue(e.key, e.value)) {
        // Chỉ update các trường có dữ liệu, giữ lại các trường cũ nếu lần đọc này bị thiếu
        _lastGoodSummary[e.key] = e.value;
      }
    }
  }

  bool _isMeaningfulHealthValue(String key, dynamic v) {
    if (v == null) return false;
    if (v is num) {
      // Với Health Connect, giá trị 0 thường không có nghĩa thông tin (trống/không được ghi)
      // Nên chỉ lấy giá trị > 0 để tránh đè dữ liệu cũ bằng giá trị rỗng.
      return v > 0;
    }
    if (v is String) {
      // Chỉ chấp nhận chuỗi không rỗng
      return v.trim().isNotEmpty;
    }
    return false;
  }

  int _effectiveStepsForDisplay(int steps, Map<String, dynamic> summary) {
    // Logic mới: Luôn lấy giá trị lớn nhất giữa "mới đọc" và "cache cũ".
    // Điều này đảm bảo số bước không bao giờ bị tụt lùi hoặc nhấp nháy về 0.
    return steps > _lastGoodSteps ? steps : _lastGoodSteps;
  }

  Map<String, dynamic> _effectiveSummaryForDisplay(
      Map<String, dynamic> summary) {
    if (summary.isNotEmpty) {
      final m = Map<String, dynamic>.from(_lastGoodSummary);
      summary.forEach((k, v) {
        if (_isMeaningfulHealthValue(k, v)) m[k] = v;
      });
      return m;
    }
    return Map<String, dynamic>.from(_lastGoodSummary);
  }

  void _syncToBackendInBackground({bool showSuccessSnackBar = false}) {
    HealthBackendSync.syncToBackend().then((saved) {
      if (!mounted) return;
      if (saved > 0 && showSuccessSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr.syncedToServer(saved))),
        );
      }
    }).catchError((e) {
      if (!mounted) return;
      // Chỉ báo lỗi khi user kéo refresh — tránh snackbar đỏ mỗi 5s khi poll nền
      if (!showSuccessSnackBar) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${context.tr.syncError}: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    });
  }

  String _resolveMetricValue({
    required String hcKey,
    required bool permissionOk,
    required int steps,
    required Map<String, dynamic> summary,
  }) {
    if (!permissionOk) return '--';

    String? asNumber(dynamic v, {int fraction = 1}) {
      if (v == null) return null;
      if (v is num) {
        if (fraction == 0) return v.round().toString();
        return v.toStringAsFixed(fraction);
      }
      return null;
    }

    switch (hcKey) {
      case 'steps':
        return '$steps';
      case 'distanceKm':
        return asNumber(summary['distanceKm'], fraction: 2) ?? '--';
      case 'caloriesKcal':
        return asNumber(summary['caloriesKcal'], fraction: 0) ?? '--';
      case 'heartRateBpm':
        return asNumber(summary['heartRateBpm'], fraction: 0) ?? '--';
      case 'bloodPressure':
        final bp = summary['bloodPressure'];
        return (bp is String && bp.isNotEmpty) ? bp : '--';
      case 'spo2Percent':
        return asNumber(summary['spo2Percent'], fraction: 0) ?? '--';
      case 'restingHeartRateBpm':
        return asNumber(summary['restingHeartRateBpm'], fraction: 0) ?? '--';
      case 'respiratoryRate':
        return asNumber(summary['respiratoryRate'], fraction: 0) ?? '--';
      case 'bodyTempC':
        return asNumber(summary['bodyTempC'], fraction: 1) ?? '--';
      case 'sleepMinutes':
        final m = summary['sleepMinutes'];
        if (m is num && m > 0) return (m / 60).toStringAsFixed(1);
        return '--';
      case 'hydrationMl':
        return asNumber(summary['hydrationMl'], fraction: 0) ?? '--';
      case 'heartRateVariabilityRmssd':
        return asNumber(summary['heartRateVariabilityRmssd'], fraction: 0) ??
            '--';
      default:
        return '--';
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: context.tr.confirmDelete,
      message: context.tr.deleteDeviceConfirm,
      confirmText: context.tr.deleteDevice,
      cancelText: context.tr.cancel,
    );

    if (ok == true) {
      await HealthConnectPrefs.clearLinked();
      if (!context.mounted) return;

      if (widget.embeddedInTab) {
        widget.onDisconnected?.call();
      } else {
        Navigator.pop(context);
      }
    }
  }

  Widget _disconnectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _showDisconnectDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D4D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          context.tr.deleteDevice,
          style:
              const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F1FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/watch.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.bluetooth, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      context.tr.connected,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Colors.black45),
        ],
      ),
    );
  }

  Widget _metricTile(_MetricViewItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Text(
                      item.value == '--'
                          ? context.tr.noData
                          : '${item.value} ${item.unit}'.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr.category(item.category),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => _loadHealthData(syncAndNotify: true),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _deviceCard(),
                                const SizedBox(height: 14),
                                const SizedBox(height: 16),
                                Text(
                                  context.tr.allMetrics,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_metrics.isEmpty)
                                  Text(
                                    context.tr.noMetrics,
                                    style: TextStyle(color: Colors.black54),
                                  )
                                else
                                  ..._metrics.map(
                                    (item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _metricTile(item),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: _disconnectButton(context),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _MetricViewItem {
  final String name;
  final String unit;
  final String value;
  final String category;
  final IconData icon;
  final Color color;

  const _MetricViewItem({
    required this.name,
    required this.unit,
    required this.value,
    required this.category,
    required this.icon,
    required this.color,
  });
}
