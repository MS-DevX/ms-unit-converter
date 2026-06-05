/// Bottom-navigation shell — hosts all five main tabs with swipe support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import 'compass_screen.dart';
import 'currency_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// Bottom-navigation host that switches between the five main screens.
///
/// Uses [PageView] so each tab retains its scroll position and widget
/// state across tab switches, and supports swipe left/right between tabs.
/// Android back button behaviour:
/// - On the Home tab (index 0): allows the OS to pop / exit.
/// - On any other tab: navigates back to index 0 instead of exiting.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const List<Widget> _screens = [
    HomeScreen(),
    CurrencyScreen(),
    CompassScreen(),
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
      icon: Icon(Icons.monetization_on_outlined),
      activeIcon: Icon(Icons.monetization_on_rounded),
      label: 'Currency',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore_rounded),
      label: 'Compass',
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
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
        body: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: _screens.map((screen) {
            return _KeepAlivePage(child: screen);
          }).toList(),
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

/// Wraps a screen widget so it survives PageView page changes.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
