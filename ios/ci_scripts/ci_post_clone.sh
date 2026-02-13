#!/bin/sh

# Set error exit
set -e

# Use the specific primary repository path provided by Xcode Cloud
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Clone Flutter into a hidden directory in the user home
# We use a single line to avoid any potential break issues
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter

# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Prepare Flutter
flutter precache --ios
flutter pub get

# Setup Pods
cd ios
pod install

exit 0
