/// App-wide navigation controller for programmatic tab switching.
///
/// Exposed via [AppNavigator.of(context)] so any widget deep in the
/// tree can switch the [MainShell] bottom-nav tab without needing a
/// direct reference to [_MainShellState].
library;

import 'package:flutter/widgets.dart';

/// Holds a callback that the [MainShell] registers to switch tabs.
///
/// Widgets call [AppNavigator.of(context).switchTab(index)] to navigate.
class AppNavigator extends InheritedNotifier<TabNotifier> {
  const AppNavigator({
    super.key,
    required TabNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Returns the nearest [AppNavigator] ancestor.
  static TabNotifier of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppNavigator>();
    assert(result != null, 'No AppNavigator found in widget tree');
    return result!.notifier!;
  }
}

/// Notifier that holds the tab-switch callback registered by [MainShell].
class TabNotifier extends ChangeNotifier {
  void Function(int index)? _switchTab;

  /// Called by [MainShell] to register its page-switch handler.
  void register(void Function(int index) handler) {
    _switchTab = handler;
  }

  /// Switches the bottom-nav to [index]. No-op if nothing is registered yet.
  void switchTab(int index) {
    _switchTab?.call(index);
  }
}

/// Singleton notifier instance shared across the app lifetime.
final appNavigator = TabNotifier();
