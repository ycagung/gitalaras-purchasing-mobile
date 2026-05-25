import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/app_bloc_provider.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/pages/home_page.dart';
import 'package:gspro/pages/login_page.dart';
import 'package:gspro/services/logger_service.dart';
import 'config.dart';
import 'theme/app_theme.dart';

void main() {
  // Add error handling for release builds
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log error in release mode
    LoggerService.error('Flutter Error: ${details.exception}');
    LoggerService.error('Stack trace: ${details.stack}');
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.error('Platform Error: $error');
    LoggerService.error('Stack trace: $stack');
    return true;
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize config
      final config = Config.instance;

      // Configure logger
      LoggerService.setEnabled(true);
      LoggerService.setLogLevel(LogLevel.debug);

      // You can use config.apiBaseUrl and config.environment here
      // For example, to configure your API client or other services

      runApp(App(config: config));
    },
    (error, stack) {
      // Handle any uncaught errors
      LoggerService.error('Uncaught error: $error');
      LoggerService.error('Stack trace: $stack');
    },
  );
}

class App extends StatelessWidget {
  final Config config;

  const App({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return AppBlocProvider(
      child: MaterialApp(
        title: 'GSPro Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const Scaffold(body: HomePage());
            } else if (state is AuthInitial ||
                (state is AuthLoading && state.isInitial)) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              // This includes AuthLoading (non-initial), AuthUnauthenticated, and AuthError
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
