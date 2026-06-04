/// Bottom-navigation shell — hosts the three main tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// Bottom-navigation host that switches between the three main screens.
///
/// Uses [IndexedStack] so each tab retains its scroll position and widget
/// state across tab switches. Android back button behaviour:
/// - On the Home tab (index 0): allows the OS to pop / exit.
/// - On any other tab: navigates back to index 0 instead of exiting.
class MainShell extends StatefulWidget {
  /// Creates a [MainShell].
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _tabAnimController;

  static const List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history_rounded),
      label: 'History',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabAnimController.value = 1.0;
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _tabAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _tabAnimController.drive(
            CurveTween(curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
          ).drive(
            Tween(begin: 0.4, end: 1.0),
          ),
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: _navItems,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
