class MonthlyFeeObligation {
  final String? id;
  final String studentId;
  final int year;
  final int month;
  final double amountDue;
  final double amountPaid;
  final String status;
  final DateTime? dueDate;

  MonthlyFeeObligation({
    this.id,
    required this.studentId,
    required this.year,
    required this.month,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.dueDate,
  });

  factory MonthlyFeeObligation.fromJson(Map<String, dynamic> json) {
    return MonthlyFeeObligation(
      id: json['id'],
      studentId: json['studentId'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      amountDue: (json['amountDue'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unpaid',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
    );
  }
}
