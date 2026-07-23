/// Adaptive navigation shell — hosts all five main tabs with responsive layout
/// support for phones (Material 3 NavigationBar) and foldables/tablets (Navigation Rail + Split Pane).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../services/navigation_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/welcome_name_dialog.dart';
import 'compass_screen.dart';
import 'converter_screen.dart';
import 'currency_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// Page physics that require a longer horizontal drag before a page transition starts.
class _ReducedSensitivityPhysics extends PageScrollPhysics {
  const _ReducedSensitivityPhysics({super.parent});

  @override
  _ReducedSensitivityPhysics applyTo(ScrollPhysics? ancestor) {
    return _ReducedSensitivityPhysics(parent: ancestor);
  }

  @override
  double get dragStartDistanceMotionThreshold => 28.0;
}

/// Adaptive navigation host supporting Compact (phone) and Expanded (tablet/foldable) screens.
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

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.currency_exchange_outlined),
      selectedIcon: Icon(Icons.currency_exchange_rounded),
      label: Text('Currency'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: Text('Compass'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: Text('History'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: Text('Settings'),
    ),
  ];

  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.currency_exchange_outlined),
      selectedIcon: Icon(Icons.currency_exchange_rounded),
      label: 'Currency',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Compass',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'History',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
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
          body: isExpanded
              ? _buildExpandedLayout()
              : _buildCompactLayout(),
        ),
      ),
    );
  }

  /// Single-column layout for Compact screens (phones in portrait) using M3 NavigationBar.
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: _navDestinations,
      ),
    );
  }

  /// Split-pane dual-column layout for Expanded screens (foldables / tablets).
  Widget _buildExpandedLayout() {
    return Row(
      children: [
        // Material 3 Navigation Rail
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: _railDestinations,
          backgroundColor: AppColors.surface,
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        ),

        const VerticalDivider(
          thickness: 1,
          width: 1,
          color: AppColors.divider,
        ),

        // Main content area
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

  /// Split pane for Home screen tab: Left pane (Categories/Search), Right pane (Active Converter).
  Widget _buildHomeSplitPane() {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPaneWidth = screenWidth > 1100 ? 420.0 : 360.0;

    return Row(
      children: [
        // Master Pane (Category Grid & Search)
        SizedBox(
          width: leftPaneWidth,
          child: const HomeScreen(),
        ),

        const VerticalDivider(
          thickness: 1,
          width: 1,
          color: AppColors.divider,
        ),

        // Detail Pane (Active Live Converter)
        const Expanded(
          child: ConverterScreen(),
        ),
      ],
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
