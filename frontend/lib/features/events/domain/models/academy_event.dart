class AcademyEvent {
  final String? id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final double? participationFee;
  final String status;

  AcademyEvent({
    this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.participationFee,
    required this.status,
  });

  factory AcademyEvent.fromJson(Map<String, dynamic> json) {
    return AcademyEvent(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: DateTime.parse(json['eventDate'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      participationFee: json['participationFee']?.toDouble(),
      status: json['status'] ?? 'Upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'participationFee': participationFee,
      'status': status,
    };
  }
}
