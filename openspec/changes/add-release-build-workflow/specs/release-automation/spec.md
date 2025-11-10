# Release Automation Specification Deltas

## ADDED Requirements

### Requirement: Automated APK Build on Release
The project SHALL automatically build an Android APK when a GitHub release is published.

#### Scenario: Build triggers on release publication
- **WHEN** a GitHub release is published (not draft)
- **THEN** a GitHub Actions workflow SHALL trigger automatically
- **AND** the workflow SHALL build a Flutter release APK for Android
- **AND** the build SHALL complete within 20 minutes

#### Scenario: Build uses stable Flutter environment
- **WHEN** the workflow executes
- **THEN** it SHALL use the latest stable Flutter SDK
- **AND** it SHALL run on ubuntu-latest GitHub runner
- **AND** it SHALL install project dependencies via `flutter pub get`
- **AND** it SHALL execute `flutter build apk --release`

### Requirement: Version-Based APK Naming
The built APK SHALL be named according to the release version extracted from the Git tag.

#### Scenario: APK naming from semantic version tag
- **WHEN** a release is created with tag `v1.0.2`
- **THEN** the version `1.0.2` SHALL be extracted from the tag
- **AND** the APK SHALL be renamed to `TimeTracker-v1.0.2.apk`
- **AND** the original `app-release.apk` filename SHALL not be used

#### Scenario: APK naming with different version formats
- **WHEN** a release is created with tag `v2.1.0`
- **THEN** the APK SHALL be named `TimeTracker-v2.1.0.apk`
- **AND** when the tag is `v0.0.1-test`
- **THEN** the APK SHALL be named `TimeTracker-v0.0.1-test.apk`

### Requirement: APK Attachment to Release
The built APK SHALL be automatically attached to the GitHub release as a downloadable asset.

#### Scenario: APK upload to release assets
- **WHEN** the APK build completes successfully
- **THEN** the renamed APK SHALL be uploaded to the GitHub release
- **AND** the APK SHALL appear in the release's assets section
- **AND** the APK SHALL be downloadable by repository users

#### Scenario: Build failure handling
- **WHEN** the APK build fails
- **THEN** the workflow SHALL fail with a clear error status
- **AND** no APK SHALL be attached to the release
- **AND** the release SHALL remain published but without the APK asset

### Requirement: Workflow Transparency
The release build process SHALL be transparent and traceable through GitHub Actions.

#### Scenario: Workflow visibility in GitHub UI
- **WHEN** a release triggers the build workflow
- **THEN** the workflow status SHALL be visible in the repository's Actions tab
- **AND** each workflow step SHALL be logged with timestamps
- **AND** build logs SHALL be accessible to repository maintainers

#### Scenario: Workflow configuration as code
- **WHEN** reviewing the project repository
- **THEN** the workflow SHALL be defined in `.github/workflows/release-build.yml`
- **AND** the workflow file SHALL include comments explaining key steps
- **AND** the workflow SHALL use pinned versions of third-party actions

### Requirement: Security and Permissions
The workflow SHALL use GitHub-provided authentication and minimal permissions.

#### Scenario: GitHub token usage
- **WHEN** the workflow executes
- **THEN** it SHALL use the `GITHUB_TOKEN` secret provided by GitHub Actions
- **AND** the token SHALL have write permissions to release assets
- **AND** no custom secrets SHALL be required for basic APK builds

#### Scenario: Debug signing for initial releases
- **WHEN** the APK is built
- **THEN** it SHALL use debug signing configuration from `android/app/build.gradle.kts`
- **AND** the APK SHALL be installable for testing purposes
- **AND** the APK SHALL not be suitable for Google Play Store distribution without production signing
