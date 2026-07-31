/// Template stub for future Schema Migration v2.
///
/// Use this file as a blueprint when introducing new tables, columns, or indexes
/// in Schema Version 2.
library;

import 'package:sqflite/sqflite.dart';

/// Schema Migration v2 (Future Stub).
///
/// Intended for upcoming features such as:
/// - Custom categories expansion
/// - Enhanced unit information metadata
/// - Index tuning
abstract class MigrationV2Stub {
  /// Executes Schema Migration v2 within an active transaction.
  static Future<void> run(Transaction txn) async {
    // Example additive migration:
    // await txn.execute('ALTER TABLE units ADD COLUMN notes TEXT;');
    // await txn.execute('CREATE INDEX IF NOT EXISTS idx_units_notes ON units(notes);');
  }
}
