import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  Timer? _tokenCheckTimer;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
    _startTokenExpiryTimer();
  }

  Future<void> checkAuthStatus() async {
    AppLogger.info('AuthCubit.checkAuthStatus checking local session...');
    emit(AuthLoading());
    try {
      final user = await _authRepository.checkSession();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    AppLogger.info('AuthCubit.login processing login for $email');
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(String name, String email, String password) async {
    AppLogger.info('AuthCubit.register processing registration for $email');
    emit(AuthLoading());
    try {
      await _authRepository.register(name, email, password);
      // Registration simulated success, redirect to login screen
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    AppLogger.info('AuthCubit.logout logging out user');
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  void _startTokenExpiryTimer() {
    _tokenCheckTimer?.cancel();
    // Check token expiration periodically (every 10 seconds)
    _tokenCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (state is AuthAuthenticated) {
        final tokens = await _authRepository.getStoredTokens();
        if (tokens != null) {
          if (tokens.isAccessTokenExpired) {
            if (tokens.isRefreshTokenExpired) {
              // Both expired, force logout
              logout();
            } else {
              // Access token expired but refresh token valid: run silent refresh
              try {
                AppLogger.info('AuthCubit daemon: access token expired. Refreshing token silently...');
                await _authRepository.refreshToken(tokens.refreshToken);
                // Keep the current authenticated state active with the refreshed tokens
                final user = await _authRepository.getStoredUser();
                if (user != null) {
                  emit(AuthAuthenticated(user));
                }
              } catch (_) {
                logout();
              }
            }
          }
        }
      }
    });
  }

  /// Exposed debug helper: forces token expiry immediately for demonstration
  Future<void> simulateTokenExpiry() async {
    AppLogger.warning('AuthCubit: Simulating token expiry immediately...');
    if (state is AuthAuthenticated) {
      await _authRepository.forceTokenExpiry();
      // Instantly run the periodic check logic rather than waiting for next tick
      final tokens = await _authRepository.getStoredTokens();
      if (tokens != null && tokens.isAccessTokenExpired) {
        try {
          await _authRepository.refreshToken(tokens.refreshToken);
          final user = await _authRepository.getStoredUser();
          if (user != null) {
            emit(AuthAuthenticated(user));
          }
        } catch (_) {
          logout();
        }
      }
    }
  }

  @override
  Future<void> close() {
    _tokenCheckTimer?.cancel();
    return super.close();
  }
}
