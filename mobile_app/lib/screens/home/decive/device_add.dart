import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_service.dart';
import 'package:Care_AI/screens/home/decive/device_sync.dart';
import 'package:Care_AI/models/tr.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  static const Color blue = Color(0xFF1877F2);
  static const Color background = Color(0xFFF6F6F6);

  List<_HealthSource> apps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    final installed = await HealthService.getInstalledHealthApps();
    final mapped = installed.map((e) {
      final supported = e['supported'] == true;
      return _HealthSource(
        name: (e['name'] ?? '').toString(),
        status: supported
            ? context.tr.readyToConnect
            : context.tr.installedNotSupported,
        supported: supported,
        iconBase64: (e['iconBase64'] as String?),
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      apps = mapped;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // 🔥 HEADER CHUẨN APP
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // 👈 back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          context.tr.dataSource,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        // 👈 giữ style giống header Care AI
        foregroundColor: Colors.black,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // SUBTITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.tr.selectHealthApp,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LIST
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : apps.isEmpty
                    ? Center(
                        child: Text(
                          context.tr.noHealthApp,
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: apps.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final source = apps[index];

                          return _deviceCard(
                            name: source.name,
                            status: source.status,
                            supported: source.supported,
                            iconBase64: source.iconBase64,
                            onTap: () {
                              if (source.supported) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllowDeviceScreen(
                                      appName: source.name,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr.notSupported(source.name),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  static Widget _deviceCard({
    required String name,
    required String status,
    required bool supported,
    String? iconBase64,
    VoidCallback? onTap,
  }) {
    Widget iconWidget;
    if (iconBase64 != null && iconBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(iconBase64);
        iconWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        iconWidget = _fallbackIcon(supported);
      }
    } else {
      iconWidget = _fallbackIcon(supported);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: supported
                    ? blue.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: iconWidget,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              supported ? Icons.arrow_forward_ios : Icons.block,
              size: 14,
              color: supported ? Colors.black54 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _fallbackIcon(bool supported) {
    return Icon(
      Icons.favorite,
      color: supported ? blue : Colors.grey,
      size: 24,
    );
  }
}

class _HealthSource {
  final String name;
  final String status;
  final bool supported;
  final String? iconBase64;

  const _HealthSource({
    required this.name,
    required this.status,
    required this.supported,
    this.iconBase64,
  });
}
