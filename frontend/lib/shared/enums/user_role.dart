enum UserRole {
  teacher('Teacher'),
  student('Student'),
  parent('Parent'),
  admin('SystemAdmin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      case 'parent':
        return UserRole.parent;
      case 'systemadmin':
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.teacher;
    }
  }
}
