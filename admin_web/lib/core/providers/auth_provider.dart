import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import '../services/api_service.dart';
import '../../models/user.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _tryRestoreSession();
  }

  void _tryRestoreSession() {
    final token = web.window.localStorage.getItem('admin_token');
    if (token != null) {
      _apiService.setToken(token);
      state = AuthState(status: AuthStatus.authenticating, token: token);
      _fetchCurrentUser();
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await _apiService.getCurrentUser();
      // Ensure user role is landlord, agent, or admin
      if (user.role == 'student') {
        throw 'Access denied. Only landlords, agents, or admins can access the admin web panel.';
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      logout();
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final data = await _apiService.login(email, password);
      final token = data['access_token'] as String;
      web.window.localStorage.setItem('admin_token', token);

      final user = await _apiService.getCurrentUser();
      if (user.role == 'student') {
        throw 'Access denied. Only landlords, agents, or admins can access the admin web panel.';
      }

      state = AuthState(status: AuthStatus.authenticated, user: user, token: token);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  void logout() {
    web.window.localStorage.removeItem('admin_token');
    web.window.localStorage.removeItem('admin_demo_mode');
    _apiService.setToken(null);
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
