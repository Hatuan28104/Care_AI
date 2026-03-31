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
  List<dynamic> report = [];
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

      print("REPORT RAW: $res");

      setState(() {
        report = res ?? [];
        loading = false;
      });
    } catch (e) {
      print("REPORT ERROR: $e");
      setState(() => loading = false);
    }
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

  List<dynamic> _filteredList() {
    if (report.isEmpty) return [];

    final usedIds = report.take(3).map((e) => e["loaichiso_id"]).toSet();

    return report.where((e) => !usedIds.contains(e["loaichiso_id"])).toList();
  }

  String formatValue(dynamic v) {
    if (v == null) return "--";
    if (v is double) return v.toStringAsFixed(1);
    return v.toString();
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
                        if (report.isNotEmpty) _mainCard(context, report[0]),
                        const SizedBox(height: 16),
                        _grid(),
                        const SizedBox(height: 16),
                        ..._filteredList()
                            .map((e) => _statItemDynamic(e))
                            .toList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= MAIN CARD ================= */

  Widget _mainCard(BuildContext context, dynamic item) {
    final value = formatValue(item["giatri"]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6EC1E4), Color(0xFF4AA3D8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, size: 40, color: Colors.red),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$value ${item["donvido"] ?? ""}",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item["tenchiso"] ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ================= GRID ================= */

  Widget _grid() {
    final small = report.skip(1).take(2).toList();

    return Row(
      children: small.map((e) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  e["tenchiso"] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "${formatValue(e["giatri"])} ${e["donvido"] ?? ""}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /* ================= LIST ================= */

  Widget _statItemDynamic(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            item["tenchiso"] ?? "",
            style: const TextStyle(color: Colors.red),
          ),
          const Spacer(),
          Text(
            "${formatValue(item["giatri"])} ${item["donvido"] ?? ""}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
