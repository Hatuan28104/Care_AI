import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_components.dart';

class ReportDetailScreen extends StatefulWidget {
  final String type;
  final String quanHeId;

  const ReportDetailScreen({
    super.key,
    required this.type,
    required this.quanHeId,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Map<String, dynamic> report = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final res = await FamilyApi.getHealthReport(
        widget.quanHeId,
        widget.type,
      );

      // 🔥 CONVERT LIST → FORMAT CŨ
      final map = _convert(res);

      setState(() {
        report = map;
        loading = false;
      });
    } catch (e) {
      print("REPORT ERROR: $e");
      setState(() => loading = false);
    }
  }

  // 🔥 MAP CS → DATA CŨ
  Map<String, dynamic> _convert(dynamic res) {
    final result = {
      "heartRate": null,
      "steps": null,
      "distance": null,
      "calories": null,
      "sleep": null,
      "temperature": null,
    };

    if (res is List) {
      for (var item in res) {
        final id = item["loaichiso_id"];
        final value = item["giatri"];

        switch (id) {
          case "CS001":
            result["heartRate"] = value;
            break;
          case "CS002":
            result["steps"] = value;
            break;
          case "CS003":
            result["calories"] = value;
            break;
          case "CS004":
            result["sleep"] = value;
            break;
          case "CS005":
            result["temperature"] = value;
            break;
          case "CS006":
            result["distance"] = value;
            break;
        }
      }
    }

    return result;
  }

  String title(BuildContext context) {
    switch (widget.type) {
      case 'week':
        return context.tr.week;
      case 'month':
        return context.tr.month;
      default:
        return context.tr.day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: title(context)),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _heartCard(context),
                        const SizedBox(height: 16),
                        _grid(),
                        const SizedBox(height: 16),
                        _statItem(
                          context.tr.steps,
                          report["steps"] != null
                              ? "${report["steps"]} ${context.tr.stepsUnit}"
                              : "--",
                        ),
                        _statItem(
                          context.tr.distance,
                          report["distance"] != null
                              ? "${report["distance"]} km"
                              : "--",
                        ),
                        _statItem(
                          context.tr.calories,
                          report["calories"] != null
                              ? "${report["calories"]} kcal"
                              : "--",
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heartCard(BuildContext context) {
    final bpm = report["heartRate"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, size: 40, color: Colors.red),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bpm != null ? "$bpm BPM" : "-- BPM",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bpm != null ? context.tr.normal : context.tr.noData,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grid() {
    return Row(
      children: [
        Expanded(
          child: _mini(
            context.tr.temperature,
            report["temperature"] != null
                ? "${report["temperature"]} °C"
                : "--",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _mini(
            context.tr.sleep,
            report["sleep"] != null ? "${report["sleep"]} h" : "--",
          ),
        ),
      ],
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.red)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
