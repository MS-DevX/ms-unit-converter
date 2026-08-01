# Database Schema & Specifications — MS Unit Converter

## Overview
MS Unit Converter uses SQLite 3 with WAL mode (`PRAGMA journal_mode = WAL;`) and foreign key enforcement (`PRAGMA foreign_keys = ON;`).

---

## Schema Tables & Record Statistics

| Table | Column Count | Description | Pre-seeded Records |
| :--- | :--- | :--- | :--- |
| `categories` | 8 | Unit categories (length, weight, temp, etc.) | 60 |
| `units` | 9 | Unit definitions & conversion factors | 480 |
| `currencies` | 7 | ISO-4217 currencies & fallback exchange rates | 151 |
| `collections` | 6 | Predefined domain collections | 18 |
| `collection_items` | 4 | UnitCategory links per collection | 126 |
| `educational_facts` | 6 | Trivia facts ("Did You Know") | 457 |
| `search_aliases` | 3 | Search keyword aliases & symbols | 242 |
| `unit_information` | 6 | Unit history, definitions & examples | 450 |
| `tags` | 2 | Domain taxonomy tags | 16 |
| `content_tags` | 3 | Tag associations to content nodes | 82 |
| `related_content` | 7 | Graph relationship edges | 26 |

---

## Indexes & Performance
1. `idx_units_category`: `(category_id, display_order)`
2. `idx_search_aliases_keyword`: `(keyword)`
3. `idx_educational_facts_category`: `(category_id)`
4. `idx_unit_info_unit_id`: `(unit_id)`
5. `idx_content_tags_source`: `(source_type, source_id)`
6. `idx_related_content_source`: `(source_type, source_id)`

---

## Performance Guarantees
- Cold repository load pass (all 7 repositories): **< 500 ms**
- Warm in-memory cache lookup: **0 ms (sub-millisecond)**
- Asset database binary size: **~540 KB**
