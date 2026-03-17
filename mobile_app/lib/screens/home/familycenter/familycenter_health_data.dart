import 'package:flutter/material.dart';
import 'package:Care_AI/models/health_icon_mapper.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/api/family_api.dart';
import '../../../models/tr.dart';
import 'package:Care_AI/widgets/app_header.dart';

class HealthDataScreen extends StatefulWidget {
  final String quanHeId;

  const HealthDataScreen({
    super.key,
    required this.quanHeId,
  });

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  static const Color _bg = Color(0xFFF6F6F6);

  List<Map<String, dynamic>> _metrics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await HealthApi.getMetrics();
      final permissions = await FamilyApi.getPermissionConfigs(widget.quanHeId);

      print("PERMISSIONS FROM DB:");
      print(permissions);

      final permissionMap = {
        for (var p in permissions)
          p["Quyen_ID"].toString().trim(): p["DaKichHoat"]
      };

      print("PERMISSION MAP:");
      print(permissionMap);

      _metrics.clear();

      for (var e in metrics) {
        if (e['Category'].toString().toLowerCase() != 'health') continue;

        final iconData = getHealthIcon(e['TenChiSo']);

        final id = e['LoaiChiSo_ID'].toString().trim();

        final raw = permissionMap[id];

        bool enabled = false;

        if (raw is bool) {
          enabled = raw;
        } else if (raw is int) {
          enabled = raw == 1;
        } else if (raw is String) {
          enabled = raw == "1" || raw.toLowerCase() == "true";
        }

        _metrics.add({
          "id": id,
          "name": e['TenChiSo'],
          "enabled": enabled,
          "icon": iconData.icon,
          "color": iconData.color,
        });
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      debugPrint("Load metrics error: $e");
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: context.tr.healthData,
            ),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  /// ================= LIST =================
  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: _metrics.length,
      itemBuilder: (_, i) {
        return _healthItem(index: i);
      },
    );
  }

  /// ================= ITEM =================
  Widget _healthItem({required int index}) {
    final m = _metrics[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(m["icon"], color: m["color"]),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              m["name"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          /// SWITCH
          Switch(
            value: m["enabled"],
            onChanged: (v) async {
              final oldValue = m["enabled"];

              setState(() {
                m["enabled"] = v;
              });

              try {
                await FamilyApi.savePermission(
                  quanHeId: widget.quanHeId,
                  quyenId: m["id"],
                  active: v,
                );
              } catch (e) {
                setState(() {
                  m["enabled"] = oldValue;
                });

                print("SAVE PERMISSION ERROR: $e");
              }
            },
            activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
            inactiveTrackColor: const Color.fromARGB(255, 218, 217, 217),
            inactiveThumbColor: Colors.white,
          )
        ],
      ),
    );
  }
}
