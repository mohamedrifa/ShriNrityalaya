import 'token_manager.dart';

class SessionManager {
  final TokenManager _tokenManager;
  String? _currentUserRole;

  SessionManager(this._tokenManager);

  String? get currentUserRole => _currentUserRole;

  void setUserRole(String? role) {
    _currentUserRole = role;
  }

  Future<bool> isAuthenticated() async {
    return await _tokenManager.hasToken();
  }

  Future<void> endSession() async {
    _currentUserRole = null;
    await _tokenManager.clearToken();
  }
}
