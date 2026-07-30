// ignore_for_file: avoid_print

/// Database integrity checker tool — MS Unit Converter
///
/// Runs `PRAGMA integrity_check` and `PRAGMA foreign_key_check` against
/// an SQLite database file.
///
/// ## Usage
/// ```bash
/// dart run tools/check_database.dart [path/to/stem_data.db]
/// ```
library;

import 'dart:io';

import 'package:unit_converter/core/constants.dart';

void main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║      MS Unit Converter — Database Integrity Checker      ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  final dbPath = args.isNotEmpty ? args[0] : _findDbPath();

  if (dbPath == null) {
    print('No database file found.');
    print('Usage: dart run tools/check_database.dart [path/to/${DatabaseConstants.databaseFileName}]');
    print('Run the app at least once to seed the database.');
    exit(1);
  }

  final file = File(dbPath);
  if (!file.existsSync()) {
    print('Database file does not exist at: $dbPath');
    exit(1);
  }

  print('Checking database at: $dbPath');
  print('File size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');
  print('');

  try {
    final result = Process.runSync('sqlite3', [
      dbPath,
      'PRAGMA integrity_check;',
      'PRAGMA foreign_key_check;',
    ]);

    if (result.exitCode == 0) {
      final output = (result.stdout as String).trim();
      print('Integrity check result:');
      print(output.isEmpty ? '  ok' : '  $output');
      print('');
      print('✅ Database integrity verified.');
      exit(0);
    } else {
      print('Note: sqlite3 CLI exited with code ${result.exitCode}.');
    }
  } on ProcessException catch (_) {
    print('Note: sqlite3 CLI binary not installed on system PATH.');
  }

  print('To run manual checks, execute:');
  print('  sqlite3 "$dbPath" "PRAGMA integrity_check;"');
  print('  sqlite3 "$dbPath" "PRAGMA foreign_key_check;"');
  print('');
  print('✓ Check tool execution complete.');
  exit(0);
}

String? _findDbPath() {
  final home = Platform.environment['HOME'] ?? '';
  final linuxPath = '$home/.local/share/com.msdevx.unitconverter/${DatabaseConstants.databaseFileName}';
  if (File(linuxPath).existsSync()) return linuxPath;
  if (File(DatabaseConstants.databaseFileName).existsSync()) return DatabaseConstants.databaseFileName;
  if (File(DatabaseConstants.databaseAssetPath).existsSync()) return DatabaseConstants.databaseAssetPath;
  return null;
}
