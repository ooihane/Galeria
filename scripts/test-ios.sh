#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/generate_project.py
simulator_id=$(xcrun simctl list devices available --json | python3 -c '
import json, sys
for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["name"].startswith("iPhone"):
            print(device["udid"])
            sys.exit(0)
raise SystemExit("No hay simulador iPhone disponible")
')
xcrun simctl boot "$simulator_id" || xcrun simctl bootstatus "$simulator_id" -b
xcrun simctl bootstatus "$simulator_id" -b
xcrun simctl privacy "$simulator_id" reset photos com.galeria.personal
xcodebuild -project Galeria.xcodeproj -scheme Galeria -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -derivedDataPath build/simulator -resultBundlePath build/PhotoPermission.xcresult \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
