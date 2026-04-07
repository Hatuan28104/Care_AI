class TimeService {
  static String nowLocalIso() {
    return DateTime.now().toLocal().toIso8601String();
  }

  static DateTime toLocal(String iso) {
    if (iso.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(iso).toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String formatFull(String iso) {
    if (iso.isEmpty) return "--:--";
    final d = toLocal(iso);
    return "${_two(d.hour)}:${_two(d.minute)} ${_two(d.day)}/${_two(d.month)}/${d.year}";
  }

  static String formatSmart(String iso) {
    if (iso.isEmpty) return "--:--";
    final d = toLocal(iso);
    final now = DateTime.now();

    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day;

    if (isToday) return "Hôm nay ${_two(d.hour)}:${_two(d.minute)}";
    if (isYesterday) return "Hôm qua ${_two(d.hour)}:${_two(d.minute)}";

    return "${_two(d.day)}/${_two(d.month)} ${_two(d.hour)}:${_two(d.minute)}";
  }

  /// ✅ Lấy ngày địa phương (dd/mm/yyyy) để group UI
  static String formatDate(String iso) {
    if (iso.isEmpty) return "--/--/----";
    final d = toLocal(iso);
    return "${_two(d.day)}/${_two(d.month)}/${d.year}";
  }

  /// ✅ Lấy giờ địa phương (hh:mm)
  static String formatTime(String iso) {
    if (iso.isEmpty) return "--:--";
    final d = toLocal(iso);
    return "${_two(d.hour)}:${_two(d.minute)}";
  }

  /// ✅ Lấy ngày địa phương thông minh (Hôm nay, Hôm qua, hoặc dd/mm/yyyy)
  static String formatDateSmart(String iso) {
    if (iso.isEmpty) return "--/--/----";
    final d = toLocal(iso);
    final now = DateTime.now();

    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;

    if (isToday) return "Hôm nay";
    if (isYesterday) return "Hôm qua";

    return "${_two(d.day)}/${_two(d.month)}/${d.year}";
  }

  /// ✅ Dành riêng cho DOB / date-only (Format: YYYY-MM-DD -> DD/MM/YYYY)
  static String formatDOB(String iso) {
    if (iso.isEmpty || iso.length < 10) return "--/--/----";
    try {
      final parts = iso.substring(0, 10).split("-");
      if (parts.length < 3) return iso;
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    } catch (e) {
      return iso;
    }
  }
}
