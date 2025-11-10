# Project Context

## Purpose
A simple, cross-platform mobile time tracking application for Android and iOS. The app allows users to track multiple concurrent tasks with persistent notifications, view historical task data in a calendar view, and manage task metadata (title, description, tags, categories).

**Key Goals:**
- Simple and intuitive time tracking
- Support for multiple simultaneous tasks
- Persistent notification with timer and controls
- Historical task viewing via calendar interface
- Modern UI with dark/light theme support

## Tech Stack
- **Framework**: Flutter (Dart)
- **Platforms**: Android (primary testing), iOS
- **Local Storage**: SQLite via sqflite package
- **State Management**: Provider or Riverpod (TBD based on complexity)
- **Notifications**: flutter_local_notifications
- **Calendar UI**: table_calendar or similar
- **Testing Device**: Connected Android phone (manual testing)

## Project Conventions

### Code Style
- Follow official Dart style guide
- Use `dart format` for consistent formatting
- Prefer `const` constructors where applicable
- Use meaningful variable names (avoid abbreviations unless common)
- File naming: `snake_case.dart`
- Class naming: `PascalCase`
- Function/variable naming: `camelCase`
- Keep files under 300 lines when possible
- One widget per file for complex widgets

### Architecture Patterns
- **Clean Architecture**: Separate business logic from UI
  - `/lib/models/` - Data models (Task, Category, Tag)
  - `/lib/services/` - Business logic (timer service, storage service)
  - `/lib/screens/` - UI screens
  - `/lib/widgets/` - Reusable UI components
  - `/lib/providers/` - State management providers
- **Repository Pattern**: Abstract data access layer for SQLite
- **Single Responsibility**: Each service handles one concern
- **Favor simplicity**: Avoid over-engineering for first version

### Testing Strategy
- Manual testing on connected Android device initially
- Unit tests for business logic (timer calculations, data models)
- Widget tests for critical UI components when app matures
- Integration tests for key user flows (start/stop task, persistence)
- Test coverage focus: data persistence, timer accuracy, notification behavior

### Git Workflow
- **Main branch**: `main` (production-ready code)
- **Feature branches**: `feature/description` or `add-description`
- **Commit conventions**: Conventional commits preferred
  - `feat:` - New features
  - `fix:` - Bug fixes
  - `refactor:` - Code restructuring
  - `docs:` - Documentation updates
  - `test:` - Test additions/changes
- Solo development: can commit directly to main for small fixes
- Use meaningful commit messages explaining "why" not just "what"

## Domain Context

### Time Tracking Concepts
- **Task**: A trackable unit of work with:
  - Required: Title
  - Optional: Description, tags (multiple), category (single)
  - Automatic: Start time, elapsed time, status (running/paused/stopped)
- **Timer States**: running, paused, stopped
- **Concurrent Tasks**: Multiple tasks can run simultaneously
- **Persistent Notification**: Background notification showing active task timer with play/pause/stop controls
- **Calendar View**: Historical view of completed tasks organized by date

### User Flows
1. **Start Task**: User creates task → notification appears → timer starts
2. **Pause/Resume**: User taps notification button → timer pauses/resumes
3. **Stop Task**: User stops task → notification dismisses → task saved to history
4. **View History**: User opens calendar → selects date → views tasks from that day

## Important Constraints
- **Platform**: Must work on Android first, iOS compatibility secondary
- **Offline-First**: No cloud sync in initial version, all data stored locally
- **Background Execution**: App must maintain timers and notifications when backgrounded
- **Battery Efficiency**: Avoid excessive wake locks or background processing
- **Simplicity First**: Start with minimal features, avoid over-engineering
- **No Authentication**: Single-user app, no login required

## External Dependencies
- **flutter_local_notifications**: For persistent notification cards
- **sqflite**: Local SQLite database for task persistence
- **path_provider**: For database file location
- **table_calendar** (or similar): Calendar UI component
- **intl**: Date/time formatting
- **State Management**: Provider or Riverpod (decide during implementation)
- **Android SDK**: For testing on connected device
- **No backend/API**: Fully local application
