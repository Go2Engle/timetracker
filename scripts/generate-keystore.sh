#!/bin/bash

# Generate Release Keystore for Android Signing
# This script helps you create a keystore for signing your Android releases

set -e

KEYSTORE_DIR="$HOME/.android-keystores"
KEYSTORE_FILE="$KEYSTORE_DIR/timetracker-release.keystore"

echo "🔐 Android Release Keystore Generator"
echo "======================================"
echo ""

# Create directory if it doesn't exist
mkdir -p "$KEYSTORE_DIR"

if [ -f "$KEYSTORE_FILE" ]; then
    echo "⚠️  WARNING: Keystore already exists at: $KEYSTORE_FILE"
    read -p "Do you want to create a new one? This will OVERWRITE the existing keystore! (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "❌ Aborted. Keeping existing keystore."
        exit 1
    fi
    echo ""
fi

echo "Please enter the following information for your keystore:"
echo "(Note: Remember these values - you'll need them for signing!)"
echo ""

read -p "Keystore password (min 6 characters): " -s STORE_PASSWORD
echo ""
read -p "Confirm keystore password: " -s STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

read -p "Key alias (e.g., 'timetracker'): " KEY_ALIAS
read -p "Key password (can be same as keystore password): " -s KEY_PASSWORD
echo ""

read -p "Your name: " DNAME_CN
read -p "Organizational unit (e.g., 'Development'): " DNAME_OU
read -p "Organization name (e.g., 'Your Name' or company): " DNAME_O
read -p "City: " DNAME_L
read -p "State/Province: " DNAME_ST
read -p "Country code (2 letters, e.g., 'US'): " DNAME_C

echo ""
echo "📝 Generating keystore..."

keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$DNAME_CN, OU=$DNAME_OU, O=$DNAME_O, L=$DNAME_L, ST=$DNAME_ST, C=$DNAME_C"

echo ""
echo "✅ Keystore created successfully!"
echo ""
echo "📍 Location: $KEYSTORE_FILE"
echo ""
echo "🔐 IMPORTANT: Save these values securely!"
echo "============================================"
echo "Keystore path: $KEYSTORE_FILE"
echo "Store password: $STORE_PASSWORD"
echo "Key alias: $KEY_ALIAS"
echo "Key password: $KEY_PASSWORD"
echo ""
echo "📋 For GitHub Actions, convert keystore to base64:"
echo "base64 -i \"$KEYSTORE_FILE\" | pbcopy"
echo "(This will copy the base64 string to your clipboard)"
echo ""
echo "⚠️  SECURITY NOTES:"
echo "- Never commit the keystore file to git"
echo "- Never share your passwords publicly"
echo "- Keep a secure backup of this keystore"
echo "- If you lose this keystore, you cannot update your app!"
echo ""
