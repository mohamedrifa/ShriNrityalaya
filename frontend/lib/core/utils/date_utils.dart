class AppDateUtils {
  static const List<String> monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String formatDate(DateTime dt) {
    final m = monthsShort[(dt.month - 1).clamp(0, 11)];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  static String formatMonthYear(int month, int year) {
    final m = monthsFull[(month - 1).clamp(0, 11)];
    return '$m $year';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
