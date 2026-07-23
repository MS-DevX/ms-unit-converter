/// Adaptive navigation shell using Google Stitch Material 3 Bottom Navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../services/in_app_update_service.dart';
import '../services/navigation_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/stitch_bottom_nav.dart';
import '../widgets/welcome_name_dialog.dart';
import 'compass_screen.dart';
import 'currency_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class _ReducedSensitivityPhysics extends PageScrollPhysics {
  const _ReducedSensitivityPhysics({super.parent});

  @override
  _ReducedSensitivityPhysics applyTo(ScrollPhysics? ancestor) {
    return _ReducedSensitivityPhysics(parent: ancestor);
  }

  @override
  double get dragStartDistanceMotionThreshold => 28.0;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const List<Widget> _screens = [
    HomeScreen(),
    CurrencyScreen(),
    CompassScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const List<StitchNavItem> _navItems = [
    StitchNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    StitchNavItem(
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments_rounded,
      label: 'Currency',
    ),
    StitchNavItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: 'Compass',
    ),
    StitchNavItem(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history_rounded,
      label: 'History',
    ),
    StitchNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
    appNavigator.register((index) {
      _onTabTapped(index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeNameDialog.showIfNeeded(context);
      // Check for Google Play In-App Updates on launch
      InAppUpdateService.instance.checkForUpdate(context: context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for Google Play In-App Updates when app resumes from background
      InAppUpdateService.instance.checkForUpdate(context: context);
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _currentIndex = index;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ResponsiveHelper.isExpanded(context);

    return AppNavigator(
      notifier: appNavigator,
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _onTabTapped(0);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: isExpanded
              ? _buildExpandedLayout()
              : _buildCompactLayout(),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const _ReducedSensitivityPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: StitchBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.surfaceContainer,
          indicatorColor: AppColors.primaryContainer,
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          unselectedIconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
          destinations: _navItems
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                ),
              )
              .toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1, color: AppColors.outlineVariant),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ],
    );
  }
}
