/// Generic base interface for all SQLite repositories in MS Unit Converter.
///
/// Standardizes data access across categories, units, collections, currencies,
/// educational facts, unit information, search aliases, tags, and related content.
library;

/// Base contract for read-only reference repositories.
abstract class BaseRepository<T, ID> {
  /// Returns all records.
  Future<List<T>> getAll();

  /// Finds a record by its unique [id]. Returns `null` if not found.
  Future<T?> getById(ID id);

  /// Searches records matching [query].
  Future<List<T>> search(String query);

  /// Returns total count of records.
  Future<int> count();

  /// Checks if a record with [id] exists.
  Future<bool> exists(ID id);

  /// Clears in-memory caches (if any).
  void clearCache();
}
