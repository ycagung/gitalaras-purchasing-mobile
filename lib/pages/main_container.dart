import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspro/theme/app_colors.dart';
import 'package:gspro/pages/home_page.dart';
import 'package:gspro/pages/profile_page.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 125,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.alizarinCrimson,
              fill: isActive ? 1 : 0,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.mono100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/backgrounds/bg-home.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: const [HomePageContent(), ProfilePageContent()],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              // Fixed notification icon
              Positioned(
                top: 0,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement notifications logic
                    print('Notifications');
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mono03,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mono30,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Symbols.notifications,
                      color: AppColors.mono100,
                      size: 20,
                      weight: 700,
                    ),
                  ),
                ),
              ),
              // Bottom navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 64,
                    width: 266,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: AppColors.mono03,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mono30,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Red capsule that slides
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          left: _currentIndex == 0 ? 0 : 125,
                          child: Container(
                            height: 48,
                            width: 125,
                            decoration: BoxDecoration(
                              color: AppColors.alizarinCrimson,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        // Buttons on top
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBottomButton(
                              icon: Symbols.home,
                              label: 'Home',
                              isActive: _currentIndex == 0,
                              onTap: () => _onTabTapped(0),
                            ),
                            _buildBottomButton(
                              icon: Symbols.person,
                              label: 'Profile',
                              isActive: _currentIndex == 1,
                              onTap: () => _onTabTapped(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
