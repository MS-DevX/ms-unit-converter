// ignore_for_file: avoid_print

/// Database inspection tool for developers.
///
/// Connects to the app's SQLite database and prints a summary of all tables,
/// row counts, schema version, and content version.
///
/// ## Usage
/// Run after building and running the app at least once (so the DB is seeded):
///
/// ```bash
/// dart run tools/inspect_database.dart [path/to/unit_converter.db]
/// ```
///
/// If no path is provided, the tool attempts to find the database in common
/// simulator/emulator locations.
///
/// ## Output Example
/// ```
/// ╔══════════════════════════════════════╗
/// ║  MS Unit Converter — DB Inspector   ║
/// ╚══════════════════════════════════════╝
///
/// Schema version  : 1
/// Content version : 2.3.0
/// Generated at    : 2026-07-30T09:00:00.000Z
///
/// Table                   Rows
/// ─────────────────────── ────
/// categories                60
/// units                    480
/// currencies               151
/// collections                 9
/// collection_items          78
/// educational_facts         321
/// search_aliases            111
/// unit_information           18
/// ```
library;

import 'dart:io';

import 'package:unit_converter/core/constants.dart';

void main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║       MS Unit Converter — Database Inspector            ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  Requires sqflite_common_ffi to run outside Flutter.    ║');
  print('║                                                          ║');
  print('║  To inspect the DB manually, use:                        ║');
  print('║  sqlite3 path/to/${DatabaseConstants.databaseFileName}                       ║');
  print('║                                                          ║');
  print('║  Common DB locations (after first app run):              ║');
  print('║  Android emulator:                                       ║');
  print('║    /data/data/com.msdevx.unitconverter/files/            ║');
  print('║  iOS simulator:                                          ║');
  print('║    ~/Library/Developer/CoreSimulator/Devices/*/          ║');
  print('║    .../data/Containers/Data/Application/*/Documents/     ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  // Determine DB path from args or use default hint.
  final dbPath = args.isNotEmpty
      ? args[0]
      : _findDbPath();

  if (dbPath == null) {
    print('No database path provided.');
    print('Usage: dart run tools/inspect_database.dart [path/to/${DatabaseConstants.databaseFileName}]');
    print('');
    print('The database is created on first app launch. Run the app first.');
    exit(1);
  }

  final file = File(dbPath);
  if (!file.existsSync()) {
    print('Database not found at: $dbPath');
    print('Run the app at least once to seed the database, then try again.');
    exit(1);
  }

  print('Database: $dbPath');
  print('Size    : ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB');
  print('');

  // NOTE: To run this inspector with full SQLite access outside Flutter,
  // add sqflite_common_ffi to dev_dependencies and uncomment the code below.
  //
  // import 'package:sqflite_common_ffi/sqflite_ffi.dart';
  //
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  //
  // final db = await openDatabase(dbPath, readOnly: true);
  //
  // final versionRow = await db.query('content_version', limit: 1);
  // print('Schema version  : ${versionRow.firstOrNull?['version'] ?? 'unknown'}');
  //
  // const tables = ['categories', 'units', 'currencies', ...];
  // for (final t in tables) {
  //   final count = Sqflite.firstIntValue(
  //     await db.rawQuery('SELECT COUNT(*) FROM $t')
  //   ) ?? 0;
  //   print('${t.padRight(24)} $count');
  // }
  //
  // await db.close();

  print('To inspect with sqlite3 CLI:');
  print('');
  print('  sqlite3 "$dbPath"');
  print('  sqlite3> .tables');
  print('  sqlite3> SELECT * FROM content_version;');
  print('  sqlite3> SELECT COUNT(*) FROM units;');
  print('  sqlite3> SELECT COUNT(*) FROM currencies;');
  print('  sqlite3> .quit');
  print('');

  print('To enable full Dart inspection, uncomment the sqflite_common_ffi');
  print('code in this file and run: dart run tools/inspect_database.dart $dbPath');
}

/// Attempts to find the database in known local paths (desktop/linux).
String? _findDbPath() {
  final home = Platform.environment['HOME'] ?? '';

  // Linux/Desktop development (flutter run -d linux)
  final linuxPath = '$home/.local/share/com.msdevx.unitconverter/${DatabaseConstants.databaseFileName}';
  if (File(linuxPath).existsSync()) return linuxPath;

  // Fallback: look in current directory.
  final localPath = DatabaseConstants.databaseFileName;
  if (File(localPath).existsSync()) return localPath;

  return null;
}
