/// Lightweight database health diagnostics service.
///
/// Provides runtime health status, schema/content versions, table row counts,
/// and integrity checks without affecting production performance.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';

/// Health diagnostic result object for the SQLite database.
@immutable
class DatabaseHealthResult {
  const DatabaseHealthResult({
    required this.isHealthy,
    required this.isInitialized,
    required this.message,
    required this.tableCounts,
    required this.errors,
    this.schemaVersion,
    this.contentVersion,
  });

  /// `true` if initialization is complete, integrity check passes, and data is readable.
  final bool isHealthy;

  /// Whether [DatabaseService.instance.isInitialized] is true.
  final bool isInitialized;

  /// Summary status message.
  final String message;

  /// Current database schema version.
  final int? schemaVersion;

  /// Current database content version.
  final String? contentVersion;

  /// Table row counts for all core reference tables.
  final Map<String, int> tableCounts;

  /// List of errors or warnings discovered during the health check.
  final List<String> errors;

  @override
  String toString() {
    return 'DatabaseHealthResult(isHealthy: $isHealthy, initialized: $isInitialized, '
        'schema: $schemaVersion, content: $contentVersion, tables: $tableCounts, errors: $errors)';
  }
}

/// Lightweight service to audit SQLite database health at runtime.
class DatabaseHealthService {
  DatabaseHealthService._();

  /// Core tables audited during health check.
  static const List<String> _auditedTables = [
    'categories',
    'units',
    'currencies',
    'collections',
    'collection_items',
    'educational_facts',
    'search_aliases',
    'unit_information',
  ];

  /// Performs a lightweight health audit of the SQLite database.
  static Future<DatabaseHealthResult> checkHealth() async {
    final errors = <String>[];
    final tableCounts = <String, int>{};

    if (!DatabaseService.instance.isInitialized) {
      return const DatabaseHealthResult(
        isHealthy: false,
        isInitialized: false,
        message: 'DatabaseService is not initialized.',
        tableCounts: {},
        errors: ['DatabaseService.instance.isInitialized is false.'],
      );
    }

    try {
      final db = DatabaseService.instance.database;

      // 1. Quick integrity check
      final pragmaRows = await db.rawQuery('PRAGMA quick_check;');
      final integrityResult = pragmaRows.isNotEmpty
          ? pragmaRows.first.values.first as String?
          : null;

      if (integrityResult != 'ok') {
        errors.add('PRAGMA quick_check failed: $integrityResult');
      }

      // 2. Read schema version
      int? schemaVersion;
      try {
        final schemaRows = await db.query('schema_version', limit: 1);
        if (schemaRows.isNotEmpty) {
          schemaVersion = schemaRows.first['version'] as int?;
        }
      } catch (e) {
        errors.add('Could not read schema_version table: $e');
      }

      // 3. Read content version
      String? contentVersion;
      try {
        final contentRows = await db.query('content_version', limit: 1);
        if (contentRows.isNotEmpty) {
          contentVersion = contentRows.first['version'] as String?;
        }
      } catch (e) {
        errors.add('Could not read content_version table: $e');
      }

      // 4. Audit table row counts
      for (final table in _auditedTables) {
        try {
          final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $table'),
          ) ?? 0;
          tableCounts[table] = count;
        } catch (e) {
          errors.add('Could not query table $table: $e');
          tableCounts[table] = -1;
        }
      }

      final isHealthy = errors.isEmpty;
      final message = isHealthy
          ? 'Database is healthy (Schema v$schemaVersion, Content v$contentVersion)'
          : 'Database health issues detected (${errors.length} error(s))';

      return DatabaseHealthResult(
        isHealthy: isHealthy,
        isInitialized: true,
        message: message,
        schemaVersion: schemaVersion,
        contentVersion: contentVersion,
        tableCounts: tableCounts,
        errors: errors,
      );
    } catch (e) {
      debugPrint('[DatabaseHealthService] Health check error: $e');
      return DatabaseHealthResult(
        isHealthy: false,
        isInitialized: true,
        message: 'Health check threw an exception: $e',
        tableCounts: tableCounts,
        errors: [e.toString()],
      );
    }
  }
}
