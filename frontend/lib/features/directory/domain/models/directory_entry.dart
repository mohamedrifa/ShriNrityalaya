class DirectoryEntry {
  final String id;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? profilePictureUrl;

  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.profilePictureUrl,
  });

  factory DirectoryEntry.fromJson(Map<String, dynamic> json) => DirectoryEntry(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    profilePictureUrl: json['profilePictureUrl'] as String?,
  );
}
