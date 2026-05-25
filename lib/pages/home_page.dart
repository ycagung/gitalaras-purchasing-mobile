import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/pages/purchase_order_list_page.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:gspro/pages/main_container.dart';
import 'package:gspro/pages/purchase_requisition_list_page.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MainContainer());
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mono30,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: AppColors.alizarinCrimson,
                  weight: 600,
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mono100,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Reload user data
      context.read<AuthBloc>().add(AuthUserLoaded(userId: authState.userId));

      // Wait for the bloc to process the event
      // The RefreshIndicator will automatically hide when the Future completes
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated
            ? (authState.user.name ?? authState.user.email.split('@')[0])
            : 'User';

        return RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 64), // Space for notification icon
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GS-PRO',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alizarinCrimson,
                          height: 1,
                        ),
                      ),
                      Text(
                        'Gitacipta PR & PO Approval',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.mono07,
                              AppColors.mono07.withOpacity(0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back! 👋',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            'Main Menu',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.alizarinCrimson,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: AppColors.alizarinCrimson,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 48),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        children: [
                          _buildMenuButton(
                            icon: Symbols.shopping_cart,
                            label: 'Purchase\nRequisition (PR)',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PurchaseRequisitionListPage(),
                                ),
                              );
                            },
                          ),
                          // _buildMenuButton(
                          //   icon: Symbols.check_circle,
                          //   label: 'PR Approval',
                          //   onTap: () {
                          //     // TODO: Navigate to PR Approval
                          //   },
                          // ),
                          _buildMenuButton(
                            icon: Symbols.receipt_long,
                            label: 'Purchase\nOrder (PO)',
                            onTap: () {
                              // TODO: Navigate to Purchase Order
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PurchaseOrderListPage(),
                                ),
                              );
                            },
                          ),
                          // _buildMenuButton(
                          //   icon: Symbols.verified,
                          //   label: 'PO Approval',
                          //   onTap: () {
                          //     // TODO: Navigate to PO Approval
                          //   },
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
