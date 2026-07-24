/// Main Shell Screen — Preserves navigation state with fluid animations.
library;

import 'package:flutter/material.dart';

import '../utils/responsive_helper.dart';
import '../widgets/stitch_bottom_nav.dart';
import 'compass_screen.dart';
import 'currency_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
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
      icon: Icons.currency_exchange_outlined,
      selectedIcon: Icons.currency_exchange_rounded,
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
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ResponsiveHelper.isExpanded(context);

    return Scaffold(
      body: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _onTabTapped(0);
          }
        },
        child: Scaffold(
          body: isExpanded
              ? _buildExpandedLayout()
              : _buildCompactLayout(),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Scaffold(
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          labelType: NavigationRailLabelType.all,
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.secondaryContainer,
          selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
          unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
          selectedLabelTextStyle: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
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
        VerticalDivider(thickness: 1, width: 1, color: colorScheme.outlineVariant),
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

class _ReducedSensitivityPhysics extends ScrollPhysics {
  const _ReducedSensitivityPhysics({super.parent});

  @override
  _ReducedSensitivityPhysics applyTo(ScrollPhysics? ancestor) {
    return _ReducedSensitivityPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 0.45;
  }
}
