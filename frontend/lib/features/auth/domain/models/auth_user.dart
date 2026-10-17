class AuthUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;
  final String? token;

  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.roles = const [],
    this.token,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    token: json['token'] as String?,
  );
}
