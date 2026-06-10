#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

export XDG_CONFIG_HOME="$PWD/.config"
export PUB_CACHE="$PWD/.pub-cache"

/Users/salonisingla/Desktop/freelance/flutter/bin/flutter pub get
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter run -d chrome
