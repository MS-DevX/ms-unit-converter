# STEM Academy Developer Content Repository

This directory contains the source of truth for all educational content in **STEM Academy**. 

All content here is processed at build-time by `tools/build_database.dart` and compiled into the pre-populated SQLite database asset (`assets/database/stem_data.db`).

> [!IMPORTANT]
> **Runtime Isolation**: The Flutter production app reads exclusively from `assets/database/stem_data.db`. The application **never** parses runtime JSON educational files.

---

## 1. Directory Structure

```text
content/
├── schema/                           ← Formal JSON Schemas for validation
│   ├── manifest.schema.json          ← Schema for content manifests
│   ├── subject.schema.json           ← Schema for subject definitions
│   ├── category.schema.json          ← Schema for category files
│   └── lesson.schema.json            ← Schema for lesson/formula entries
│
└── academy/                          ← Educational Content Library
    ├── manifest.json                 ← Top-level content manifest
    │
    ├── mathematics/                  ← Mathematics Subject Directory
    │   ├── manifest.json             ← Subject manifest listing categories
    │   ├── algebra.json              ← Algebra lessons & formulas
    │   ├── geometry.json             ← Geometry lessons & formulas
    │   ├── trigonometry.json         ← Trigonometry lessons & formulas
    │   ├── coordinate_geometry.json  ← Coordinate Geometry lessons
    │   ├── calculus.json             ← Calculus lessons & formulas
    │   ├── probability.json          ← Probability lessons
    │   ├── statistics.json           ← Statistics lessons
    │   ├── matrices.json             ← Matrices lessons
    │   ├── vectors.json              ← Vectors lessons
    │   └── logarithms.json           ← Logarithms lessons
    │
    ├── physics/ (future)             ← Physics Subject Directory
    ├── chemistry/ (future)           ← Chemistry Subject Directory
    ├── engineering/ (future)         ← Engineering Subject Directory
    └── computer_science/ (future)    ← Computer Science Subject Directory
```

---

## 2. Permanent String Identifiers

All lessons, formulas, and relationship linkages must use permanent dot-notated string identifiers:

- **Format**: `<subject>.<category>.<slug>`
- **Examples**:
  - `math.algebra.quadratic_formula`
  - `math.geometry.pythagorean_theorem`
  - `math.trigonometry.law_of_sines`

### Numeric IDs
Each lesson also contains a unique `numeric_id` integer (e.g. `101`, `102`) for backwards compatibility with SQLite integer primary keys.

---

## 3. Dynamic Content Discovery

`tools/build_database.dart` discovers content recursively:
1. Reads `content/academy/manifest.json` for declared subjects.
2. For available subjects, loads the subject manifest (e.g., `content/academy/mathematics/manifest.json`).
3. Discovers category JSON files declared in the subject manifest.
4. Compiles subjects, categories, formulas, variables, worked examples, and `related_content` into SQLite tables in `stem_data.db`.

---

## 4. Developer Validation Workflow

Before building or committing database changes, run the content validation tools:

```bash
# 1. Run static content linter (checks manifests, schemas, unique IDs, and required fields)
dart run tools/lint_content.dart

# 2. Run structural infrastructure validator
dart run tools/validate_content.dart

# 3. Generate pre-populated SQLite database binary asset
flutter test test/build_database_runner_test.dart

# 4. Run database health diagnostic check
dart run tools/check_database.dart assets/database/stem_data.db
```

---

## 5. Adding New Subjects or Categories

### Adding a New Category (e.g. Linear Algebra to Mathematics):
1. Create `content/academy/mathematics/linear_algebra.json` following `content/schema/category.schema.json`.
2. Add category entry to `content/academy/mathematics/manifest.json`:
   ```json
   {
     "id": "linear_algebra",
     "file": "linear_algebra.json",
     "name": "Linear Algebra",
     "emoji": "🔢"
   }
   ```
3. Run `dart run tools/lint_content.dart` and `flutter test test/build_database_runner_test.dart`.

### Adding a New Subject (e.g. Physics):
1. Create `content/academy/physics/manifest.json`.
2. Declare `physics` subject in `content/academy/manifest.json`:
   ```json
   {
     "id": "physics",
     "numeric_id": 2,
     "name": "Physics",
     "icon": "⚛️",
     "is_available": true,
     "display_order": 2,
     "manifest_path": "physics/manifest.json"
   }
   ```
3. Add modular category JSON files under `content/academy/physics/`.
