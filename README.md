# TimeTracker

A simple, cross-platform mobile time tracking application built with Flutter for Android and iOS.

## Features

### Task Management
- Create and track multiple tasks simultaneously
- Add titles, descriptions, tags, and categories to tasks
- Start, pause, and stop timers for each task
- View detailed task information and edit task metadata

### Calendar View
- View tasks organized by date in a calendar interface
- See task counts for each day
- Review historical task data

### Reports & Analytics
- Filter tasks by tags and categories
- View total time spent across filtered tasks
- Export filtered task data to CSV for external analysis
- CSV files include: title, description, timestamps, elapsed time, status, category, and tags

### Notifications
- Persistent notifications with running timers
- Play/pause/stop controls directly from the notification
- Continue tracking time even when the app is in the background

### Settings
- Theme support (light/dark mode based on system settings)
- Task and metadata management

## Usage

### Creating Tasks
1. Tap the "+" button on the Tasks screen
2. Enter a task title (required)
3. Optionally add a description, select tags, and assign a category
4. Tap "Create" to start tracking

### Filtering and Reports
1. Navigate to the Reports tab in the bottom navigation
2. Select one or more tags to filter tasks (AND logic - tasks must have all selected tags)
3. Optionally select a category from the dropdown
4. View the total time for filtered tasks displayed at the top
5. Tap "Export CSV" to save the report to your device

#### CSV Export Location
- **Android**: Saved to app's external storage directory (accessible via Files app)
- **iOS**: Saved to app's documents directory (accessible via Files app)
- **Filename format**: `timetracker_report_YYYYMMDD_HHMMSS.csv`

#### CSV File Format
The exported CSV includes the following columns:
- Title
- Description
- Start Time (YYYY-MM-DD HH:MM:SS)
- End Time (YYYY-MM-DD HH:MM:SS)
- Elapsed Time (HH:MM:SS)
- Status
- Category
- Tags (comma-separated)

A summary row at the end shows the total elapsed time.

### Managing Categories and Tags
1. Go to Settings screen
2. Create, edit, or delete categories (with custom colors)
3. Create, edit, or delete tags for organizing tasks

## Technical Details

- **Framework**: Flutter (Dart)
- **Platforms**: Android, iOS
- **Database**: SQLite (sqflite)
- **Local Storage**: All data stored on-device (no cloud sync)
- **Notifications**: flutter_local_notifications

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode for platform-specific builds
- A connected device or emulator

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch on a connected device

### Testing
- Manual testing on Android device recommended
- Unit tests: `flutter test`

## Releases

### Creating a Release

This project uses GitHub Actions to automatically build and attach Android APK files to releases.

**To create a release:**

1. Ensure the version in `pubspec.yaml` matches your desired release version
2. Create and push a tag following the format `v{major}.{minor}.{patch}`:
   ```bash
   git tag v1.0.2
   git push origin v1.0.2
   ```
3. Create a GitHub release from the tag (via GitHub web UI or CLI)
4. The GitHub Actions workflow will automatically:
   - Build a release APK
   - Name it `TimeTracker-v{version}.apk` (e.g., `TimeTracker-v1.0.2.apk`)
   - Attach it to the release

**Important:** The tag must start with `v` followed by semantic versioning (e.g., `v1.0.2`, `v2.1.0`).

### Downloading Releases

APK files are available in the [Releases](../../releases) section. Download the latest `TimeTracker-v{version}.apk` file and install it on your Android device.

**Note:** Current releases use debug signing and are suitable for testing and development. They are not signed for Google Play Store distribution.

## Project Structure
```
lib/
├── models/          # Data models (Task, Tag, Category)
├── repositories/    # Database access layer
├── services/        # Business logic (timer, notifications, exports)
├── screens/         # UI screens
├── widgets/         # Reusable UI components
└── utils/           # Helper functions
```

## License

This project is a private application for personal time tracking.
