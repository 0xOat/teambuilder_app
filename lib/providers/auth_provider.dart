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
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final success = await _pbService.login(email, password);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: success,
        errorMessage: success ? null : 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final success = await _pbService.register(name, email, password);
      
      if (success) {
        // หลังสมัครเสร็จให้ login อัตโนมัติ
        await login(email, password);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ไม่สามารถสมัครสมาชิกได้ อีเมลนี้อาจถูกใช้ไปแล้ว',
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  Future<void> logout() async {
    await _pbService.logout();
    state = AuthState.initial();
  }

  void checkAuthStatus() {
    state = state.copyWith(isAuthenticated: _pbService.isLoggedIn);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      errorMessage: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}