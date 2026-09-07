import 'package:flutter_riverpod/legacy.dart';

class AuthState {
  final bool isAuthenticated;
  final String userRole;

  AuthState({this.isAuthenticated = false, this.userRole = 'Teacher'});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setRole(String role) {
    state = AuthState(isAuthenticated: true, userRole: role);
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
