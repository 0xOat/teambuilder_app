import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pocketbase_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  final _pbService = PocketBaseService();

  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    final success = await _pbService.login(email, password);
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: success,
    );
  }

  Future<void> logout() async {
    await _pbService.logout();
    state = AuthState.initial();
  }

  void checkAuthStatus() {
    state = state.copyWith(isAuthenticated: _pbService.isLoggedIn);
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}