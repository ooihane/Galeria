#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v xcodebuild >/dev/null; then
  echo 'Esta compilación necesita macOS con Xcode. Usa el workflow manual de GitHub Actions.' >&2
  exit 1
fi
python3 scripts/generate_project.py
xcodebuild -version
xcodebuild -project Galeria.xcodeproj -scheme Galeria -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build/device \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
python3 scripts/package_ipa.py
