// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/database/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Generates pre-populated SQLite database file', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final absolutePath = path.join(
      Directory.current.path,
      'assets',
      'database',
      DatabaseConstants.databaseFileName,
    );

    final targetFile = File(absolutePath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final db = await openDatabase(absolutePath);
    try {
      await DatabaseService.seedDatabase(db);
      await db.execute('VACUUM;');
      await db.execute('PRAGMA optimize;');
    } finally {
      await db.close();
    }

    final file = File(absolutePath);
    expect(await file.exists(), isTrue);
    final length = await file.length();
    expect(length, greaterThan(10000));
    print('Generated $absolutePath successfully ($length bytes)');
  });
}
