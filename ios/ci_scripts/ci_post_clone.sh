#!/bin/sh

# Fail on error
set -e

# The CI_WORKSPACE is the root of your git repo
cd $CI_WORKSPACE

# 1. Install Flutter
git clone https://github.com -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Precache artifacts and get packages
flutter precache --ios
flutter pub get

# 3. Install CocoaPods dependencies
cd ios
pod install
