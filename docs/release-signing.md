# Release Signing Setup for TimeTracker

This guide explains how to set up proper release signing for the TimeTracker app so it can be distributed via GitHub releases and updated through Obtainium.

## Overview

The app uses a release keystore to sign Android builds. The keystore is:
- **Never committed to the repository** (it's in `.gitignore`)
- **Stored as a GitHub secret** for automated builds
- **Kept locally** for manual builds

This ensures that all releases have the same signature, allowing seamless updates via Obtainium.

## One-Time Setup

### Step 1: Generate Your Release Keystore

Run the keystore generation script:

```bash
./scripts/generate-keystore.sh
```

This will:
1. Prompt you for keystore information (name, organization, passwords, etc.)
2. Create a keystore at `~/.android-keystores/timetracker-release.keystore`
3. Display the information you need to save

**⚠️ CRITICAL**: Save all the keystore information securely:
- Keystore file location
- Store password
- Key alias
- Key password

**If you lose this keystore, you cannot update your app!** Users would need to uninstall and reinstall.

### Step 2: Create Local Key Properties File

Create `android/key.properties` (this file is git-ignored):

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` with your actual values:

```properties
storeFile=/Users/YOUR_USERNAME/.android-keystores/timetracker-release.keystore
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

### Step 3: Add Secrets to GitHub

1. Convert your keystore to base64:
   ```bash
   base64 -i ~/.android-keystores/timetracker-release.keystore | pbcopy
   ```
   (This copies the base64 string to your clipboard)

2. Go to your GitHub repository settings:
   - Navigate to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**

3. Add these four secrets:

   | Name | Value |
   |------|-------|
   | `KEYSTORE_BASE64` | Paste the base64 string from step 1 |
   | `KEYSTORE_PASSWORD` | Your keystore password |
   | `KEY_ALIAS` | Your key alias |
   | `KEY_PASSWORD` | Your key password |

## Building Releases

### Automated Builds (Recommended)

The GitHub Actions workflow automatically builds and publishes releases when you push a version tag:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.2+3  # Format: versionName+versionCode
   ```

2. Commit and push your changes:
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.2"
   git push
   ```

3. Create and push a git tag:
   ```bash
   git tag v1.0.2
   git push origin v1.0.2
   ```

4. GitHub Actions will automatically:
   - Build the release APK
   - Sign it with your keystore
   - Create a GitHub release
   - Attach the APK to the release

### Manual Local Builds

If you need to build locally:

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Installing via Obtainium

Users can install and auto-update your app using Obtainium:

1. Install [Obtainium](https://github.com/ImranR98/Obtainium)
2. Add your app with this URL: `https://github.com/YOUR_USERNAME/timetracker`
3. Obtainium will track releases and notify about updates

## Version Numbering

Version format in `pubspec.yaml`: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

Example: `1.0.2+3`
- `1.0.2` → Android `versionName` (visible to users)
- `3` → Android `versionCode` (must increase with each release)

**Important**: Always increment the build number (+3, +4, +5...) for each release, even if the version name stays the same. Otherwise, Android will reject the update.

## Troubleshooting

### "Installation conflict" in Obtainium

This usually means:
- The `versionCode` wasn't incremented
- The signing key is different from the previous version

**Solution**: Make sure you:
1. Increment the build number in `pubspec.yaml`
2. Use the same keystore for all releases

### "Could not find signingConfig"

If you get this error during build:
1. Verify `android/key.properties` exists and has correct values
2. Check that the keystore file path is correct
3. For GitHub Actions, verify all four secrets are set

### Testing the signing configuration

To verify your local setup works:

```bash
flutter build apk --release
```

Check the build output - it should NOT show "Signing with the debug keys".

## Security Notes

- ✅ The keystore file is in `.gitignore` and will never be committed
- ✅ GitHub secrets are encrypted and only accessible to Actions
- ✅ The keystore is deleted from the runner after each build
- ⚠️ Keep a secure backup of your keystore file
- ⚠️ Never share your keystore passwords publicly
- ⚠️ Store your keystore backup separately from your code

## Backup Your Keystore

Create a backup of your keystore in a secure location:

```bash
# Create an encrypted backup
cp ~/.android-keystores/timetracker-release.keystore ~/secure-backups/
```

Consider storing it in:
- A password manager
- Encrypted cloud storage
- An offline encrypted USB drive

**Remember**: Losing your keystore means you cannot update your app!
