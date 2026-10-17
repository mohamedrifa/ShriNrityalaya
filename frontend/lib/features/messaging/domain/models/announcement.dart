class Announcement {
  final String id;
  final String title;
  final String content;
  final String? authorName;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.authorName,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    authorName: json['authorName'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    if (authorName != null) 'authorName': authorName,
    'createdAt': createdAt.toIso8601String(),
  };
}
