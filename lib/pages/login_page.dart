import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/auth/auth_bloc.dart';
import 'package:gspro/bloc/auth/auth_event.dart';
import 'package:gspro/bloc/auth/auth_state.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/backgrounds/bg-login.png'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: Icon(
                              Symbols.help,
                              color: AppColors.alizarinCrimson,
                              size: 20,
                              weight: 500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GS-PRO',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username field
                          Text(
                            'Username',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mono100,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              hintText: 'Your email address',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mono60,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                                borderSide: BorderSide(color: AppColors.mono30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                                borderSide: BorderSide(
                                  color: AppColors.alizarinCrimson,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Password field
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mono100,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              hintText: 'Password',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mono60,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                                borderSide: BorderSide(color: AppColors.mono30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(36),
                                borderSide: BorderSide(
                                  color: AppColors.alizarinCrimson,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Symbols.visibility
                                      : Symbols.visibility_off,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 48),
                          // Login button
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is AuthError) {
                                // Clear any existing snackbars first
                                ScaffoldMessenger.of(context).clearSnackBars();
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.message.isNotEmpty
                                          ? state.message
                                          : 'Login failed. Please try again.',
                                    ),
                                    backgroundColor: AppColors.alizarinCrimson,
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                              } else if (state is AuthAuthenticated) {
                                // Clear inputs on successful login
                                _usernameController.clear();
                                _passwordController.clear();
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        try {
                                          if (_usernameController.text.isEmpty ||
                                              _passwordController.text.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please enter email and password',
                                                ),
                                                backgroundColor:
                                                    AppColors.alizarinCrimson,
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          // Dispatch login event
                                          context.read<AuthBloc>().add(
                                            AuthLoginRequested(
                                              email: _usernameController.text
                                                  .trim(),
                                              password: _passwordController.text,
                                            ),
                                          );
                                        } catch (e) {
                                          // Show error if button click fails
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'An error occurred: ${e.toString()}',
                                              ),
                                              backgroundColor:
                                                  AppColors.alizarinCrimson,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  backgroundColor: isLoading
                                      ? AppColors.mono30
                                      : AppColors.alizarinCrimson,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          // Forgot password
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password logic
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.mono100,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '©2025 GS-PRO. All rights reserved.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.mono70,
                      ),
                    ),
                    Text(
                      'v1.4.0-build.1102',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.mono70,
                      ),
                    ),
                  ],
                  // Add your content here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
