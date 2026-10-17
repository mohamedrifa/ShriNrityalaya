extension StringExtensions on String {
  String get capitalize {
    if (trim().isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get toInitials {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
