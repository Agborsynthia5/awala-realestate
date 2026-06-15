import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Completes once the initial secure-storage read finishes. Login must await
  /// this to avoid a slow first-read migration overwriting a fresh login.
  late final Future<void> _initFuture;

  AuthNotifier(this._apiService) : super(const AuthState(status: AuthStatus.authenticating)) {
    _initFuture = _tryRestoreSession();
  }

  Future<void> _persistToken(String? token) async {
    if (token == null) {
      await _storage.delete(key: AppConstants.accessTokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.accessTokenKey);
      return;
    }
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, token);
  }

  Future<void> _tryRestoreSession() async {
    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token == null) {
        if (state.status != AuthStatus.authenticated) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
        return;
      }
      _apiService.setToken(token);
      state = AuthState(status: AuthStatus.authenticating, token: token);
      final user = await _apiService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user, token: token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Session restore failed: $e');
      }
      await _persistToken(null);
      if (state.status != AuthStatus.authenticated) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<void> login(String email, String password) async {
    await _initFuture;
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final data = await _apiService.login(email, password);
      final token = data['access_token'] as String;
      await _persistToken(token);
      final user = await _apiService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user, token: token);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e is String ? e : e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _initFuture;
    await _persistToken(null);
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
