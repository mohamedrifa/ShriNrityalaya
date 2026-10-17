class AppFormatters {
  static String formatCurrency(num amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  static String formatScore(int score, {int max = 100}) {
    return '$score/$max';
  }

  static String formatInitials(String firstName, [String lastName = '']) {
    final f = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final l = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? 'ST' : combined;
  }
}
