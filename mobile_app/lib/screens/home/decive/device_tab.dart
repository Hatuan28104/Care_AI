import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_service.dart';
import 'package:Care_AI/screens/home/decive/device_add.dart';
import 'package:Care_AI/screens/home/decive/device_detail.dart';
import 'package:Care_AI/services/health_connect_prefs.dart';

/// Tab Thiết bị trong [HomeScreen]: đã đồng bộ + còn quyền HC → hiện [DeviceDetailScreen] luôn;
/// chưa thì hiện màn kết nối (card + nút).
class DeviceTabRouter extends StatefulWidget {
  const DeviceTabRouter({super.key});

  @override
  State<DeviceTabRouter> createState() => _DeviceTabRouterState();
}

class _DeviceTabRouterState extends State<DeviceTabRouter> {
  late Future<_DeviceEntry> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadEntry();
  }

  Future<_DeviceEntry> _loadEntry() async {
    final linked = await HealthConnectPrefs.isLinked();
    final perm = await HealthService.checkPermission();
    final name = await HealthConnectPrefs.getLinkedAppName();
    final appName = (name != null && name.isNotEmpty) ? name : 'Huawei Health';
    return _DeviceEntry(showDetail: linked && perm, appName: appName);
  }

  void _reloadAfterDisconnect() {
    setState(() {
      _future = _loadEntry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DeviceEntry>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final e = snapshot.data!;
        if (e.showDetail) {
          return DeviceDetailScreen(
            appName: e.appName,
            embeddedInTab: true,
            onDisconnected: _reloadAfterDisconnect,
          );
        }
        return const DeviceConnectPlaceholder();
      },
    );
  }
}

class _DeviceEntry {
  final bool showDetail;
  final String appName;

  _DeviceEntry({required this.showDetail, required this.appName});
}

/// Chưa kết nối: card + nút vào luồng chọn app / cấp quyền.
class DeviceConnectPlaceholder extends StatelessWidget {
  const DeviceConnectPlaceholder({super.key});

  static const Color accent = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        _deviceCard(),
        const Spacer(),
        const SizedBox(height: 10),
        _button(context),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _deviceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/decive.jpg',
          width: 200,
        ),
      ),
    );
  }

  Widget _button(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddDeviceScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: accent.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Kết nối dữ liệu',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
