# Change: Add Task Model and Storage

## Why
The app needs a foundational data layer to persist task information locally. Without a proper data model and storage mechanism, tasks cannot be created, tracked, or retrieved for historical viewing. This is the foundation upon which all other features (timers, notifications, calendar view) will be built.

## What Changes
- Add Task data model with all required and optional fields
- Implement SQLite database schema for task persistence
- Create repository pattern for CRUD operations on tasks
- Add database initialization and migration support
- Implement data access layer with type-safe queries
- Add support for categories and tags as task metadata

## Impact
- Affected specs: **task-storage** (new capability)
- Affected code: 
  - New: `lib/models/task.dart`
  - New: `lib/models/category.dart`
  - New: `lib/models/tag.dart`
  - New: `lib/services/database_service.dart`
  - New: `lib/repositories/task_repository.dart`
  - New: `pubspec.yaml` (add sqflite, path_provider dependencies)
- No breaking changes
- Establishes database schema that other features will depend on
