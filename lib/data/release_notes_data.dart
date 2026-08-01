import 'package:flutter/material.dart';
import '../models/release_notes.dart';

/// Registry of all bundled release notes for MS Unit Converter.
const List<ReleaseNotes> allReleaseNotes = [
  ReleaseNotes(
    version: '2.4.0+8',
    displayVersion: '2.4.0',
    title: "What's New",
    subtitle: 'Version 2.4.0',
    headerDescription:
        'Thank you for updating Unit Converter!\n\nThis release includes major improvements to search, educational content, collections, performance, and overall reliability.',
    sections: [
      ReleaseSection(
        title: 'Smarter Search',
        icon: Icons.search_rounded,
        items: [
          'Faster offline search',
          'Better keyword recognition',
          'Improved abbreviations',
          'Better symbol matching',
          'Improved natural language search',
        ],
      ),
      ReleaseSection(
        title: 'Expanded Knowledge',
        icon: Icons.auto_awesome_rounded,
        items: [
          'Educational information for every unit',
          'Hundreds of new educational facts',
          'Better explanations',
          'Richer offline reference content',
        ],
      ),
      ReleaseSection(
        title: 'Curated Collections',
        icon: Icons.collections_bookmark_rounded,
        items: [
          'Discover useful converter collections including Engineering, Science, Travel, Cooking, Fitness, Everyday, Medical, Automotive, Electrical, Astronomy, and many more.',
        ],
      ),
      ReleaseSection(
        title: 'Performance Improvements',
        icon: Icons.speed_rounded,
        items: [
          'Faster startup',
          'Faster database loading',
          'Better search performance',
          'Improved memory usage',
          'Smoother scrolling',
        ],
      ),
      ReleaseSection(
        title: 'Reliability Improvements',
        icon: Icons.verified_user_rounded,
        items: [
          'Improved stability',
          'Internal optimizations',
          'Better offline experience',
          'General bug fixes',
          'Fixed an issue where the profile image could occasionally disappear after some time.',
        ],
      ),
    ],
    footer: 'Thank you for using Unit Converter ❤️\nBuilt with Love by MS DevX',
  ),
];

/// Returns the latest release notes object or null if none registered.
ReleaseNotes? getLatestReleaseNotes() {
  if (allReleaseNotes.isEmpty) return null;
  return allReleaseNotes.first;
}

/// Finds release notes for a specific version string (or null if not found).
ReleaseNotes? getReleaseNotesForVersion(String version) {
  for (final notes in allReleaseNotes) {
    if (notes.version == version || notes.displayVersion == version) {
      return notes;
    }
  }
  return getLatestReleaseNotes();
}
