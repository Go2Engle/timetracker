# Proposal: Add GitHub Release Build Workflow

## Change ID
`add-release-build-workflow`

## Status
Proposed

## Context
The TimeTracker Flutter application currently lacks automated build and release infrastructure. When creating a GitHub release, there's no automated process to build the Android APK and attach it to the release. This requires manual builds and uploads, which is error-prone and time-consuming.

The project uses Flutter for cross-platform development with Android as the primary platform. Releases follow semantic versioning (e.g., v1.0.2) where the tag and release name include the version number.

## Motivation
- **Automation**: Eliminate manual APK building and uploading for each release
- **Consistency**: Ensure every release has a properly versioned APK attached
- **Naming Convention**: Standardize APK naming as `TimeTracker-v{version}.apk` (e.g., `TimeTracker-v1.0.2.apk`)
- **Version Sync**: Automatically extract version from release tag to maintain consistency
- **Distribution**: Provide easy access to release APKs for testers and users

## Scope

### In Scope
- GitHub Actions workflow triggered on release creation
- Automated Flutter environment setup (latest stable)
- Android APK build using Flutter release mode
- Version extraction from release tag (format: `v{major}.{minor}.{patch}`)
- APK naming with version: `TimeTracker-v{version}.apk`
- APK attachment to the GitHub release
- Java/Android SDK configuration for Flutter builds

### Out of Scope
- iOS app builds (not included in this workflow)
- Code signing with production keys (uses debug signing initially)
- Google Play Store publishing
- Multi-variant builds (debug, profile, staging)
- App Bundle (AAB) generation for Play Store
- Automated testing before build
- Version bumping in `pubspec.yaml` (manual process remains)
- Release notes generation

## Proposed Solution

Create a GitHub Actions workflow (`.github/workflows/release-build.yml`) that:

1. **Triggers** on release publication events (`published` type)
2. **Extracts** version number from the release tag (e.g., `v1.0.2` → `1.0.2`)
3. **Sets up** Flutter environment with latest stable SDK
4. **Installs** dependencies via `flutter pub get`
5. **Builds** release APK using `flutter build apk --release`
6. **Renames** APK from `app-release.apk` to `TimeTracker-v{version}.apk`
7. **Uploads** the renamed APK as a release asset

### Technical Details
- **Workflow file**: `.github/workflows/release-build.yml`
- **Trigger**: `on: release: types: [published]`
- **Runner**: `ubuntu-latest` (sufficient for Android builds)
- **Flutter Action**: `subosito/flutter-action@v2` (community standard)
- **Version extraction**: GitHub Actions expression from `github.ref` (refs/tags/v1.0.2)
- **APK location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Upload method**: GitHub CLI (`gh release upload`) or Actions toolkit

## Implementation Plan
See `tasks.md` for detailed implementation steps.

## Dependencies
- GitHub Actions enabled on repository
- Repository write permissions for workflow to upload assets
- No additional Flutter dependencies beyond current `pubspec.yaml`

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Build fails due to Flutter version mismatch | Release has no APK | Pin to stable channel, add error notifications |
| Tag format doesn't match expected pattern | Version extraction fails | Document tag format requirement, add validation |
| Build requires signing keys not in CI | APK won't be production-ready | Document that initial builds use debug signing |
| Workflow timeout on large builds | Build fails | Set reasonable timeout (20 min), optimize build cache |
| APK upload fails | Release incomplete | Add retry logic, validate upload success |

## Success Criteria
- [ ] GitHub workflow file exists at `.github/workflows/release-build.yml`
- [ ] Workflow triggers automatically when a release is published
- [ ] APK builds successfully in release mode
- [ ] APK is named `TimeTracker-v{version}.apk` matching release tag
- [ ] APK is automatically attached to the GitHub release
- [ ] Workflow completes within 15 minutes
- [ ] Documentation includes instructions for creating releases with proper tags

## Open Questions
None - requirements are clear and straightforward.

## References
- [GitHub Actions: Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Flutter GitHub Actions setup](https://docs.flutter.dev/deployment/cd#github-actions)
- [Flutter build APK documentation](https://docs.flutter.dev/deployment/android#building-the-app-for-release)
- Current `pubspec.yaml` version: 1.0.0+1
