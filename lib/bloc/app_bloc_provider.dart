import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/order/order_bloc.dart';
import 'package:gspro/bloc/requisition/requisition_bloc.dart';
import 'package:gspro/repositories/auth_repository.dart';
import 'package:gspro/repositories/order_repository.dart';
import 'package:gspro/repositories/requisition_repository.dart';
import 'package:gspro/services/api_service.dart';
import 'package:gspro/services/token_refresh_service.dart';

class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ApiService (single instance for all repositories)
    final apiService = ApiService.instance;
    
    // Initialize repositories
    final authRepository = AuthRepository(apiService);
    final requisitionRepository = RequisitionRepository(apiService);
    final orderRepository = OrderRepository(apiService);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = AuthBloc(authRepository: authRepository);
            // Set session expiration callback in ApiService
            // This will trigger logout when token refresh fails
            apiService.setSessionExpiredCallback(() {
              authBloc.add(const AuthLogoutRequested());
            });
            return authBloc;
          },
        ),
        BlocProvider<RequisitionBloc>(
          create: (context) => RequisitionBloc(
            requisitionRepository: requisitionRepository,
          ),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(orderRepository: orderRepository),
        ),
      ],
      child: _TokenRefreshWrapper(child: child),
    );
  }
}

// Wrapper widget to manage token refresh service lifecycle
class _TokenRefreshWrapper extends StatefulWidget {
  final Widget child;

  const _TokenRefreshWrapper({required this.child});

  @override
  State<_TokenRefreshWrapper> createState() => _TokenRefreshWrapperState();
}

class _TokenRefreshWrapperState extends State<_TokenRefreshWrapper> {
  final TokenRefreshService _tokenRefreshService = TokenRefreshService();

  @override
  void initState() {
    super.initState();
    // Start token refresh service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tokenRefreshService.start(context);
    });
  }

  @override
  void dispose() {
    _tokenRefreshService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

