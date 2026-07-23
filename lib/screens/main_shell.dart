/// Adaptive navigation shell using Google Stitch Material 3 Bottom Navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../services/navigation_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/stitch_bottom_nav.dart';
import '../widgets/welcome_name_dialog.dart';
import 'compass_screen.dart';
import 'converter_screen.dart';
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
    _pageController = PageController(initialPage: 0);
    appNavigator.register((index) {
      _onTabTapped(index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeNameDialog.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          setState(() => _currentIndex = index);
        },
        children: _screens.map((screen) {
          return _KeepAlivePage(child: screen);
        }).toList(),
      ),
      bottomNavigationBar: StitchBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
      ),
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => _onTabTapped(index),
          labelType: NavigationRailLabelType.selected,
          destinations: _navItems.map((item) {
            return NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            );
          }).toList(),
          backgroundColor: AppColors.surface,
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedIconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
          color: AppColors.outlineVariant,
        ),
        Expanded(
          child: _currentIndex == 0
              ? _buildHomeSplitPane()
              : IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
        ),
      ],
    );
  }

  Widget _buildHomeSplitPane() {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPaneWidth = screenWidth > 1100 ? 420.0 : 360.0;

    return Row(
      children: [
        SizedBox(
          width: leftPaneWidth,
          child: const HomeScreen(),
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
          color: AppColors.outlineVariant,
        ),
        const Expanded(
          child: ConverterScreen(),
        ),
      ],
    );
  }
}

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
