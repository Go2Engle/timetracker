# Implementation Tasks: Add GitHub Release Build Workflow

## Prerequisites
- [x] Verify GitHub Actions is enabled on repository
- [x] Confirm write permissions for GITHUB_TOKEN (should be default)
- [x] Review current `pubspec.yaml` version (currently `1.0.0+1`)

## Implementation Tasks

### 1. Create Workflow Directory Structure
- [x] Create `.github/workflows/` directory if it doesn't exist
- [x] Verify directory permissions allow file creation

### 2. Create GitHub Actions Workflow File
- [x] Create `.github/workflows/release-build.yml`
- [x] Add workflow name: `Build and Release APK`
- [x] Configure trigger: `on: release: types: [published]`
- [x] Set runner: `ubuntu-latest`
- [x] Set timeout: `20 minutes`

### 3. Implement Version Extraction Step
- [x] Add step to extract version from tag
- [x] Use shell parameter expansion: `VERSION=${GITHUB_REF#refs/tags/v}`
- [x] Store version in step output: `echo "version=$VERSION" >> $GITHUB_OUTPUT`
- [x] Assign step ID: `get_version` for reference in later steps

### 4. Implement Flutter Environment Setup
- [x] Add checkout step using `actions/checkout@v4`
- [x] Add Flutter setup step using `subosito/flutter-action@v2`
- [x] Configure Flutter channel to `stable`
- [x] Add `flutter pub get` step to install dependencies

### 5. Implement APK Build Step
- [x] Add build step with command: `flutter build apk --release`
- [x] Verify build output path: `build/app/outputs/flutter-apk/app-release.apk`
- [x] Add appropriate step name for clarity

### 6. Implement APK Rename Step
- [x] Add rename step using `mv` command
- [x] Source: `build/app/outputs/flutter-apk/app-release.apk`
- [x] Target: `TimeTracker-v${{ steps.get_version.outputs.version }}.apk`
- [x] Verify version variable reference syntax

### 7. Implement Release Upload Step
- [x] Add upload step using `softprops/action-gh-release@v1`
- [x] Configure `files` parameter with renamed APK path
- [x] Set `GITHUB_TOKEN` environment variable: `${{ secrets.GITHUB_TOKEN }}`
- [x] Add step name: `Upload APK to release`

### 8. Add Workflow Comments
- [x] Add header comment explaining workflow purpose
- [x] Add inline comments for version extraction logic
- [x] Document APK path and naming convention
- [x] Add comment about GITHUB_TOKEN auto-provisioning

## Testing & Validation

### 9. Test Workflow Locally (Optional)
- [ ] Install `act` tool for local GitHub Actions testing (optional)
- [ ] Run workflow locally with test tag if `act` is available
- [ ] Verify each step executes without errors

### 10. Create Test Release
- [ ] Create test tag: `git tag v0.0.1-test`
- [ ] Push tag: `git push origin v0.0.1-test`
- [ ] Create GitHub release from tag
- [ ] Monitor workflow execution in Actions tab

### 11. Verify Test Release Build
- [ ] Confirm workflow triggers automatically
- [ ] Check workflow completes without errors
- [ ] Verify APK appears in release assets
- [ ] Verify APK filename: `TimeTracker-v0.0.1-test.apk`
- [ ] Download APK and verify it's a valid Android package

### 12. Test APK Installation
- [ ] Download test APK from release
- [ ] Install on Android device or emulator
- [ ] Verify app launches successfully
- [ ] Check app version in UI (if version is displayed)
- [ ] Uninstall test APK

### 13. Clean Up Test Release
- [ ] Delete test release from GitHub
- [ ] Delete test tag: `git tag -d v0.0.1-test` (local)
- [ ] Delete remote tag: `git push origin :refs/tags/v0.0.1-test`

## Documentation

### 14. Document Release Process
- [x] Add "Releases" section to `README.md`
- [x] Document tag format requirement: `v{major}.{minor}.{patch}`
- [x] Explain automated APK build and attachment
- [x] Add example: Creating release v1.0.2

### 15. Add Inline Documentation
- [x] Review workflow YAML for clarity
- [x] Ensure all steps have descriptive names
- [x] Add comments explaining non-obvious logic
- [x] Document version extraction approach

## Final Validation

### 16. Code Review Checklist
- [x] Workflow triggers only on release publication
- [x] Version extraction handles expected tag format
- [x] Flutter setup uses stable channel
- [x] APK naming follows convention: `TimeTracker-v{version}.apk`
- [x] Upload step references correct APK path
- [x] GITHUB_TOKEN has required permissions
- [x] Timeout allows sufficient build time (20 min)

### 17. Security Review
- [x] No secrets hardcoded in workflow
- [x] GITHUB_TOKEN used (auto-provided, scoped)
- [x] Third-party actions pinned to version (subosito, softprops)
- [x] No sensitive data in APK build

### 18. Merge and Monitor
- [ ] Create pull request with workflow file
- [ ] Request review if team collaboration
- [ ] Merge to main branch
- [ ] Monitor next actual release for successful build

## Success Validation
- [x] Workflow file exists at `.github/workflows/release-build.yml`
- [ ] Workflow passes `actionlint` or similar linting (if available)
- [ ] Test release completes successfully
- [ ] APK naming matches expected format
- [ ] APK is attached to release automatically
- [x] Documentation updated with release process
- [x] No breaking changes to existing workflows

## Notes
- **Tag Format**: Tags must follow `v{semver}` format (e.g., `v1.0.2`, `v2.1.0`)
- **Build Time**: Expect 5-10 minutes for first build, faster with caching
- **Debug Signing**: Initial builds use debug signing; production signing is a future enhancement
- **Platform**: Workflow only builds Android APK; iOS builds are out of scope
