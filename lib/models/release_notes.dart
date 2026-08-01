import 'package:flutter/widgets.dart';

/// Represents a single grouped section within a version release note.
@immutable
class ReleaseSection {
  /// The section header title (e.g. 'Smarter Search', 'Expanded Knowledge').
  final String title;

  /// Icon associated with this release section.
  final IconData icon;

  /// List of feature/improvement bullet items within this section.
  final List<String> items;

  const ReleaseSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

/// Represents complete release notes data for a specific app version release.
@immutable
class ReleaseNotes {
  /// The app release version string matching package_info (e.g. '2.4.0+8').
  final String version;

  /// User-facing display version (e.g. '2.4.0').
  final String displayVersion;

  /// Main dialog title (e.g. "What's New").
  final String title;

  /// Subtitle string (e.g. "Version 2.4.0").
  final String subtitle;

  /// Header description message thanking the user and summarizing updates.
  final String headerDescription;

  /// Grouped release sections.
  final List<ReleaseSection> sections;

  /// Footer message (e.g. "Thank you for using Unit Converter ❤️").
  final String footer;

  const ReleaseNotes({
    required this.version,
    required this.displayVersion,
    required this.title,
    required this.subtitle,
    required this.headerDescription,
    required this.sections,
    required this.footer,
  });
}
