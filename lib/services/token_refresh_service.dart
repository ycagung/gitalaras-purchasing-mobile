import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/services/logger_service.dart';
import 'package:gspro/services/token_storage_service.dart';

class TokenRefreshService {
  Timer? _refreshTimer;
  static const int _checkIntervalSeconds = 60; // Check every minute
  static const int _refreshBeforeExpirySeconds = 120; // Refresh 2 minutes before expiry

  /// Start the automatic token refresh service
  void start(BuildContext? context) {
    stop(); // Stop any existing timer
    
    if (context == null) {
      LoggerService.warning('TokenRefreshService: Context is null, cannot start');
      return;
    }

    LoggerService.info('TokenRefreshService: Starting automatic token refresh');
    
    // Check immediately
    _checkAndRefresh(context);
    
    // Then check every minute
    _refreshTimer = Timer.periodic(
      const Duration(seconds: _checkIntervalSeconds),
      (_) => _checkAndRefresh(context),
    );
  }

  /// Stop the automatic token refresh service
  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    LoggerService.info('TokenRefreshService: Stopped automatic token refresh');
  }

  /// Check if token needs refresh and trigger it
  Future<void> _checkAndRefresh(BuildContext context) async {
    try {
      final isExpiredOrExpiring = await TokenStorageService.isTokenExpiredOrExpiringSoon();
      
      if (isExpiredOrExpiring) {
        final timeUntilExpiry = await TokenStorageService.getTimeUntilExpiry();
        
        if (timeUntilExpiry != null && timeUntilExpiry <= _refreshBeforeExpirySeconds) {
          LoggerService.info(
            'TokenRefreshService: Token expiring soon (${timeUntilExpiry}s remaining), refreshing...',
          );
          
          // Trigger refresh via AuthBloc
          if (context.mounted) {
            final authBloc = context.read<AuthBloc>();
            final authState = authBloc.state;
            
            // Only refresh if authenticated
            if (authState is AuthAuthenticated) {
              authBloc.add(const AuthRefreshRequested());
            }
          }
        } else if (timeUntilExpiry == null || timeUntilExpiry <= 0) {
          LoggerService.warning('TokenRefreshService: Token expired, attempting refresh...');
          
          if (context.mounted) {
            final authBloc = context.read<AuthBloc>();
            final authState = authBloc.state;
            
            if (authState is AuthAuthenticated) {
              authBloc.add(const AuthRefreshRequested());
            }
          }
        }
      }
    } catch (e) {
      LoggerService.error('TokenRefreshService: Error checking token expiry: $e');
    }
  }

  /// Manually trigger a token refresh
  Future<void> refreshNow(BuildContext? context) async {
    if (context == null) {
      LoggerService.warning('TokenRefreshService: Context is null, cannot refresh');
      return;
    }

    LoggerService.info('TokenRefreshService: Manual refresh requested');
    
    if (context.mounted) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      
      if (authState is AuthAuthenticated) {
        authBloc.add(const AuthRefreshRequested());
      }
    }
  }
}

