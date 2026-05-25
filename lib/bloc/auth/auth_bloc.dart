import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/models/user.dart';
import 'package:gspro/repositories/auth_repository.dart';
import 'package:gspro/services/api_service.dart';
import 'package:gspro/services/device_service.dart';
import 'package:gspro/services/logger_service.dart';
import 'package:gspro/services/token_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRefreshRequested>(_onRefreshRequested);
    on<AuthCheckSessionRequested>(_onCheckSessionRequested);
    on<AuthUserLoaded>(_onUserLoaded);

    // Check for existing session on initialization
    add(const AuthCheckSessionRequested());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    LoggerService.info('Login requested for email: ${event.email}');
    emit(const AuthLoading());

    try {
      // Wrap entire login process in timeout to prevent infinite loading
      final device = await DeviceService.getDevice();
      LoggerService.info('Device info retrieved, calling login API...');
      
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
        device: device,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          LoggerService.error('Login request timed out');
          throw TimeoutException('Login request timed out');
        },
      );

      final loginResponse = result.fold((error) {
        LoggerService.error('Login failed with error: $error');
        emit(AuthError(message: error));
        return null;
      }, (response) {
        LoggerService.info('Login API call successful');
        return response;
      });

      if (loginResponse != null) {
        LoggerService.info('Saving tokens to storage...');
        // Save tokens to storage
        await TokenStorageService.saveTokens(
          accessToken: loginResponse.accessToken,
          sessionId: loginResponse.sessionId,
          userId: loginResponse.userId,
        );

        // Reset session expired flag on successful login
        ApiService.instance.resetSessionExpiredFlag();

        // Load user data after successful login
        LoggerService.info('Fetching user data...');
        Either<String, User> userResult;
        try {
          userResult = await _authRepository.getCurrentUser().timeout(
            const Duration(seconds: 30),
          );
        } on TimeoutException {
          LoggerService.warning('getCurrentUser timed out, using minimal user');
          userResult = const Left('Request timed out');
        }
        
        userResult.fold(
          (error) {
            // If getting user fails, still authenticate with minimal user data
            // This allows the app to continue even if user fetch fails
            LoggerService.warning(
              'getCurrentUser failed: $error, using minimal user',
            );
            final minimalUser = User(
              id: loginResponse.userId,
              email: event.email,
              password: '', // Not needed after login
            );
            LoggerService.info('Emitting AuthAuthenticated with minimal user');
            emit(
              AuthAuthenticated(
                user: minimalUser,
                accessToken: loginResponse.accessToken,
                sessionId: loginResponse.sessionId,
                userId: loginResponse.userId,
              ),
            );
          },
          (user) {
            LoggerService.info('Login successful, emitting AuthAuthenticated');
            emit(
              AuthAuthenticated(
                user: user,
                accessToken: loginResponse.accessToken,
                sessionId: loginResponse.sessionId,
                userId: loginResponse.userId,
              ),
            );
          },
        );
      } else {
        LoggerService.warning('Login response is null, error should have been emitted');
      }
    } on TimeoutException catch (e) {
      LoggerService.error('Login timeout: ${e.toString()}');
      emit(AuthError(
        message: 'Request timed out. Please check your internet connection and try again.',
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Login error: ${e.toString()}');
      LoggerService.error('Stack trace: $stackTrace');
      
      // Ensure we always emit an error state, never leave it in loading
      String errorMessage = 'An unexpected error occurred. Please try again.';
      
      if (e.toString().contains('timeout') || 
          e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('SocketException') ||
                 e.toString().contains('network') ||
                 e.toString().contains('Failed host lookup')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      }
      
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      LoggerService.warning('Logout API call failed: $e');
      // Continue with logout even if API call fails
    }
    await TokenStorageService.clearTokens();
    // Clear the session expired callback to prevent further logout attempts
    ApiService.instance.clearSessionExpiredCallback();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final userId = await TokenStorageService.getUserId();
    final sessionId = await TokenStorageService.getSessionId();

    if (userId == null || sessionId == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _authRepository.refresh(
      userId: userId,
      sessionId: sessionId,
    );

    final refreshResponse = result.fold((error) {
      // If refresh fails, clear tokens and logout
      // Note: clearTokens is async but we fire-and-forget it here
      // to avoid blocking the emit
      TokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
      return null;
    }, (response) => response);

    if (refreshResponse != null) {
      // Update access token in storage
      await TokenStorageService.saveTokens(
        accessToken: refreshResponse.accessToken,
        sessionId: sessionId,
        userId: userId,
      );

      // Reload user data
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (error) {
          // If getting user fails, try to get user from current state or create minimal user
          if (state is AuthAuthenticated) {
            final currentState = state as AuthAuthenticated;
            emit(
              AuthAuthenticated(
                user: currentState.user,
                accessToken: refreshResponse.accessToken,
                sessionId: sessionId,
                userId: userId,
              ),
            );
          } else {
            // Create minimal user if we don't have current state
            final minimalUser = User(id: userId, email: '', password: '');
            emit(
              AuthAuthenticated(
                user: minimalUser,
                accessToken: refreshResponse.accessToken,
                sessionId: sessionId,
                userId: userId,
              ),
            );
          }
        },
        (user) => emit(
          AuthAuthenticated(
            user: user,
            accessToken: refreshResponse.accessToken,
            sessionId: sessionId,
            userId: userId,
          ),
        ),
      );
    }
  }

  /// App opening flow:
  /// 1. Check if userId and sessionId exists
  /// 2. If yes, do auth refresh
  /// 3. If auth refresh success, go straight to homepage (emit AuthAuthenticated)
  /// 4. Otherwise go to login page (emit AuthUnauthenticated)
  Future<void> _onCheckSessionRequested(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // If already authenticated, don't check again
    if (state is AuthAuthenticated) {
      LoggerService.info(
        'AuthBloc: Already authenticated, skipping session check',
      );
      return;
    }

    // Step 1: Check for userId and sessionId first (these are persistent)
    // Even if accessToken is expired or missing, we can try to refresh
    final userId = await TokenStorageService.getUserId();
    final sessionId = await TokenStorageService.getSessionId();

    if (userId == null || sessionId == null) {
      // Step 4: No userId or sessionId found -> go to login page
      LoggerService.info(
        'AuthBloc: No userId or sessionId found, emitting AuthUnauthenticated',
      );
      // Clear any remaining tokens
      await TokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
      return;
    }

    // Step 2: userId and sessionId found -> attempt auth refresh
    LoggerService.info(
      'AuthBloc: userId and sessionId found, attempting to refresh token...',
    );
    emit(const AuthLoading(isInitial: true));

    // Directly call refresh instead of adding event to avoid async timing issues
    final result = await _authRepository.refresh(
      userId: userId,
      sessionId: sessionId,
    );

    final refreshResponse = result.fold((error) {
      // Step 4: Auth refresh failed -> go to login page
      LoggerService.warning('AuthBloc: Session refresh failed: $error');
      // If refresh fails, clear tokens and logout
      TokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
      return null;
    }, (response) => response);

    if (refreshResponse != null) {
      // Step 3: Auth refresh success -> go straight to homepage
      LoggerService.info('AuthBloc: Session refresh successful');
      // Update access token in storage
      await TokenStorageService.saveTokens(
        accessToken: refreshResponse.accessToken,
        sessionId: sessionId,
        userId: userId,
      );

      // Reload user data
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (error) {
          LoggerService.warning(
            'AuthBloc: getCurrentUser failed during session check: $error',
          );
          // Create minimal user if we can't get full user data
          final minimalUser = User(id: userId, email: '', password: '');
          emit(
            AuthAuthenticated(
              user: minimalUser,
              accessToken: refreshResponse.accessToken,
              sessionId: sessionId,
              userId: userId,
            ),
          );
        },
        (user) {
          LoggerService.info(
            'AuthBloc: Session check successful, user authenticated',
          );
          emit(
            AuthAuthenticated(
              user: user,
              accessToken: refreshResponse.accessToken,
              sessionId: sessionId,
              userId: userId,
            ),
          );
        },
      );
    }
  }

  Future<void> _onUserLoaded(
    AuthUserLoaded event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (error) {
          // If getting user fails, keep the current authenticated state
          // Don't emit error as it would redirect to login
          // Just log the error and keep using the existing user data
          LoggerService.warning(
            'Failed to reload user data: $error, keeping current user',
          );
          // Keep the current authenticated state
          emit(
            AuthAuthenticated(
              user: currentState.user,
              accessToken: currentState.accessToken,
              sessionId: currentState.sessionId,
              userId: currentState.userId,
            ),
          );
        },
        (user) => emit(
          AuthAuthenticated(
            user: user,
            accessToken: currentState.accessToken,
            sessionId: currentState.sessionId,
            userId: currentState.userId,
          ),
        ),
      );
    }
  }
}
