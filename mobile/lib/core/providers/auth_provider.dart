import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  static const _storage = FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(const AuthState()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    _apiService.setToken(token);
    state = AuthState(status: AuthStatus.authenticating, token: token);
    try {
      final user = await _apiService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user, token: token);
    } catch (_) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final data = await _apiService.login(email, password);
      final token = data['access_token'] as String;
      await _storage.write(key: AppConstants.accessTokenKey, value: token);
      final user = await _apiService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user, token: token);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    _apiService.setToken(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final currentUserProvider = Provider<Map<String, String>>((ref) {
  final auth = ref.watch(authProvider);
  final user = auth.user;
  if (user == null) {
    return const {'name': 'Guest', 'email': ''};
  }
  return {
    'name': user['name']?.toString() ?? 'User',
    'email': user['email']?.toString() ?? '',
  };
});
