class Lesson {
  final String? id;
  final String batchId;
  final String title;
  final String? description;
  final String? videoUrl;
  final int orderSequence;

  Lesson({
    this.id,
    required this.batchId,
    required this.title,
    this.description,
    this.videoUrl,
    required this.orderSequence,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      batchId: json['batchId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['videoUrl'],
      orderSequence: json['orderSequence'] ?? 0,
    );
  }
}
