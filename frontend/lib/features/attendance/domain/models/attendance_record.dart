class AttendanceRecord {
  final String studentId;
  final String classSessionId;
  final String status;
  final DateTime? date;

  const AttendanceRecord({
    required this.studentId,
    required this.classSessionId,
    required this.status,
    this.date,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'classSessionId': classSessionId,
    'status': status,
    if (date != null) 'date': date!.toIso8601String(),
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
    studentId: json['studentId'] as String? ?? '',
    classSessionId: json['classSessionId'] as String? ?? '',
    status: json['status'] as String? ?? 'Present',
    date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
  );
}
