abstract class AuthService {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<String?> getCurrentUserRole();
  Future<bool> isLoggedIn();
}
