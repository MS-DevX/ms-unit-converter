/// Subject data model for STEM Academy platform.
library;

/// Represents a STEM subject (e.g. Mathematics, Physics, Chemistry).
class SubjectModel {
  final int id;
  final String name;
  final String icon;
  final bool isAvailable;
  final int displayOrder;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isAvailable,
    required this.displayOrder,
  });

  factory SubjectModel.fromRow(Map<String, dynamic> row) {
    return SubjectModel(
      id: row['id'] as int,
      name: row['name'] as String,
      icon: row['icon'] as String? ?? '📚',
      isAvailable: (row['is_available'] as int? ?? (row['id'] == 1 ? 1 : 0)) == 1,
      displayOrder: row['display_order'] as int? ?? 0,
    );
  }
}
