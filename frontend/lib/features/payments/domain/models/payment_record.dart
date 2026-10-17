class PaymentRecord {
  final String id;
  final String obligationId;
  final num amount;
  final String paymentMethod;
  final String transactionReference;
  final DateTime paymentDate;
  final String status;

  const PaymentRecord({
    required this.id,
    required this.obligationId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionReference,
    required this.paymentDate,
    required this.status,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    id: json['id'] as String? ?? '',
    obligationId: json['obligationId'] as String? ?? '',
    amount: (json['amount'] as num?) ?? 0,
    paymentMethod: json['paymentMethod'] as String? ?? '',
    transactionReference: json['transactionReference'] as String? ?? '',
    paymentDate: json['paymentDate'] != null
        ? DateTime.parse(json['paymentDate'] as String)
        : DateTime.now(),
    status: json['status'] as String? ?? 'Completed',
  );
}
