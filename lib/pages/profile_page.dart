import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/pages/main_container.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MainContainer());
  }
}

class ProfilePageContent extends StatelessWidget {
  const ProfilePageContent({super.key});

  Widget _buildTransparentButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        alignment: Alignment.centerLeft,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mono100,
            ),
          ),
          Icon(
            Symbols.chevron_right,
            size: 20,
            color: AppColors.mono100,
            weight: 600,
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
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;
        final userName = user.name ?? user.email.split('@')[0];
        final userDisplayId = user.employeeId ?? user.id;
        final avatarUrl = user.avatar != null && user.avatar!.isNotEmpty
            ? user.avatar!
            : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&size=80&background=E91E63&color=fff';

        return RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 64), // Space for notification icon
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.alizarinCrimson,
                  ),
                ),
                Text(
                  'ID: $userDisplayId',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mono03,
                        AppColors.mono03.withOpacity(0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      Text(
                        'Account',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alizarinCrimson,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildTransparentButton(
                        label: 'My Profile',
                        onTap: () {
                          // TODO: Navigate to My Profile
                        },
                      ),
                      SizedBox(height: 8),
                      _buildTransparentButton(
                        label: 'Change Password',
                        onTap: () {
                          // TODO: Navigate to Change Password
                        },
                      ),
                      SizedBox(height: 24),
                      // Separator line
                      Divider(color: AppColors.mono30, thickness: 1),
                      SizedBox(height: 24),
                      // Support Section
                      Text(
                        'Support',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alizarinCrimson,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildTransparentButton(
                        label: 'Help',
                        onTap: () {
                          // TODO: Navigate to Help
                        },
                      ),
                      SizedBox(height: 24),
                      // Separator line
                      Divider(color: AppColors.mono30, thickness: 1),
                      SizedBox(height: 24),
                      // Logout Section (no title)
                      _buildTransparentButton(
                        label: 'Logout',
                        onTap: () {
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        },
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
