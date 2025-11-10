# Design: Add GitHub Release Build Workflow

## Overview
This change introduces a GitHub Actions workflow to automate Android APK builds when GitHub releases are created. The workflow extracts the version from the release tag, builds a Flutter release APK, renames it to match the versioning convention, and attaches it to the release.

## Architecture

### Workflow Trigger
```yaml
on:
  release:
    types: [published]
```

**Rationale**: The `published` type fires when a release transitions from draft to published OR when a new release is created directly. This avoids building for draft releases and ensures builds only happen for finalized releases.

**Alternatives Considered**:
- `created`: Fires for drafts too, wasting CI resources
- `released`: Deprecated in favor of `published`

### Version Extraction Strategy

**Input**: GitHub release tag in format `v{major}.{minor}.{patch}` (e.g., `v1.0.2`)  
**Output**: Version string without 'v' prefix (e.g., `1.0.2`)

**Implementation**:
```yaml
- name: Extract version from tag
  id: get_version
  run: |
    VERSION=${GITHUB_REF#refs/tags/v}
    echo "version=$VERSION" >> $GITHUB_OUTPUT
```

**Why this approach**:
- Uses POSIX shell parameter expansion for simplicity
- No external dependencies (jq, sed) required
- Works with ubuntu-latest runner's default shell
- Stores in `$GITHUB_OUTPUT` for use in subsequent steps

**Tag format validation**: The workflow assumes tags follow `v{semver}` format. Invalid formats will result in incorrect APK naming but won't fail the build. Documentation will specify the required tag format.

### Build Environment

**Runner**: `ubuntu-latest`
- **Pro**: Fast provisioning, free for public repos
- **Con**: Linux-only (fine for Android builds)

**Flutter Setup**: `subosito/flutter-action@v2`
- Community-maintained, 9k+ stars
- Supports channel selection (stable/beta/dev)
- Caches Flutter SDK between runs
- Configuration:
  ```yaml
  - uses: subosito/flutter-action@v2
    with:
      channel: 'stable'
  ```

**Java/Android SDK**: Included in `ubuntu-latest` runner by default
- Java 11+ available (required for Flutter Android builds)
- Android SDK components pre-installed
- No additional setup steps needed

### Build Process

**Dependency Installation**:
```bash
flutter pub get
```

**APK Build Command**:
```bash
flutter build apk --release
```

**Flags**:
- `--release`: Optimized, minified, no debug symbols
- No `--split-per-abi`: Generates universal APK (larger but compatible with all ABIs)

**Build Output Location**: `build/app/outputs/flutter-apk/app-release.apk`

**Why universal APK**:
- Simpler for direct distribution (one file)
- Users don't need to know their device ABI
- Split APKs are for Play Store optimization (out of scope)

### APK Naming & Upload

**Rename Step**:
```bash
mv build/app/outputs/flutter-apk/app-release.apk \
   TimeTracker-v${{ steps.get_version.outputs.version }}.apk
```

**Upload to Release**:
```yaml
- name: Upload APK to release
  uses: softprops/action-gh-release@v1
  with:
    files: TimeTracker-v${{ steps.get_version.outputs.version }}.apk
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Why `softprops/action-gh-release`**:
- Purpose-built for release asset uploads
- Handles GITHUB_TOKEN automatically
- Supports multiple files and overwrite scenarios
- 3.5k+ stars, actively maintained
- Simpler than GitHub CLI for this use case

**Alternatives Considered**:
- GitHub CLI (`gh release upload`): More setup, less declarative
- `actions/upload-artifact`: Wrong tool (for workflow artifacts, not releases)

## Code Signing

**Current Approach**: Uses debug signing config from `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**Implications**:
- APKs won't be installable alongside Google Play versions
- Not suitable for production distribution
- Sufficient for testing, internal distribution, and development

**Future Enhancement** (out of scope):
- Add production signing keys to GitHub Secrets
- Configure `signingConfigs.release` in Gradle
- Reference secrets in workflow environment

## Error Handling

**Build Failures**:
- Workflow fails fast if any step errors
- GitHub UI shows failure status on release page
- Notification sent to repository watchers (configurable)

**Invalid Tag Format**:
- Version extraction succeeds but produces incorrect version
- APK will be named incorrectly (e.g., `TimeTracker-v1.0.2-beta.apk` if tag is `v1.0.2-beta`)
- **Mitigation**: Document tag format in CONTRIBUTING.md or release documentation

**Upload Failures**:
- `action-gh-release` automatically retries transient failures
- Permanent failures (network, permissions) fail the workflow
- No manual cleanup needed - failed releases can be deleted and recreated

## Performance Considerations

**Build Duration**: ~5-10 minutes on ubuntu-latest
- Flutter SDK download & setup: ~1-2 min (cached after first run)
- `flutter pub get`: ~30 sec
- `flutter build apk --release`: ~3-6 min
- Upload: ~10-30 sec

**Caching Strategy**:
- Flutter SDK: Cached by `flutter-action`
- Pub dependencies: Not cached initially (can optimize later with `actions/cache`)
- Build artifacts: Ephemeral, not cached

**Timeout**: Set to 20 minutes to allow headroom for slow builds

## Security Considerations

**GITHUB_TOKEN Permissions**:
- Automatically provided by GitHub Actions
- Scoped to repository
- Has write access to releases (required for asset upload)
- No manual secret configuration needed

**Dependency Security**:
- `subosito/flutter-action`: Community action, verify version before use
- `softprops/action-gh-release`: Community action, verify version before use
- **Best Practice**: Pin actions to commit SHA for immutability

**Code Exposure**:
- APK contains compiled Dart code (not source)
- Debug symbols stripped in release mode
- No secrets embedded in code (verified in code review)

## Testing Strategy

**Pre-merge Testing**:
1. Test workflow in forked repository or feature branch
2. Create test release with tag `v0.0.1-test`
3. Verify workflow triggers and completes
4. Verify APK naming matches expected pattern
5. Download and install APK on Android device
6. Verify app version matches release tag

**Validation Criteria**:
- [ ] Workflow completes without errors
- [ ] APK file appears in release assets
- [ ] APK filename format: `TimeTracker-v{version}.apk`
- [ ] APK is installable on Android device
- [ ] App version in About screen matches release tag

## Workflow YAML Structure

```yaml
name: Build and Release APK

on:
  release:
    types: [published]

jobs:
  build-apk:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - name: Extract version from tag
        id: get_version
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          echo "version=$VERSION" >> $GITHUB_OUTPUT
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Rename APK
        run: |
          mv build/app/outputs/flutter-apk/app-release.apk \
             TimeTracker-v${{ steps.get_version.outputs.version }}.apk
      
      - name: Upload APK to release
        uses: softprops/action-gh-release@v1
        with:
          files: TimeTracker-v${{ steps.get_version.outputs.version }}.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Documentation Updates

**Required Documentation**:
1. **README.md**: Add "Releases" section explaining how to create releases
2. **CONTRIBUTING.md** (if exists): Document release process and tag format
3. Inline workflow comments: Explain each step for maintainability

**Tag Format Documentation**:
```markdown
## Creating Releases

To create a release with automated APK builds:

1. Ensure `pubspec.yaml` version matches desired release version
2. Create and push a tag in format `v{major}.{minor}.{patch}` (e.g., `v1.0.2`)
3. Create GitHub release from the tag
4. Workflow automatically builds and attaches `TimeTracker-v1.0.2.apk`

**Important**: Tag must start with 'v' followed by semantic version (e.g., v1.0.2)
```

## Future Enhancements (Not in Scope)

1. **App Bundle Generation**: Build AAB for Play Store publishing
2. **Multi-variant Builds**: Debug, staging, production APKs
3. **Automated Testing**: Run tests before build
4. **Code Signing**: Production signing keys from secrets
5. **iOS Builds**: Add parallel iOS build job
6. **Build Matrix**: Test multiple Flutter versions
7. **Dependency Caching**: Speed up `flutter pub get`
8. **Release Notes**: Auto-generate from commits
9. **Version Validation**: Ensure pubspec.yaml matches tag
10. **Slack/Discord Notifications**: Alert on build completion

## Rollback Plan

If workflow causes issues:
1. Disable workflow via GitHub UI (Settings > Actions)
2. Delete `.github/workflows/release-build.yml`
3. Return to manual build process
4. No data loss - releases remain intact
