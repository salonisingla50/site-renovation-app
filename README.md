# School Site Tracker

A Flutter Android app MVP for photo-first school/site maintenance tracking.

## What is included

- Registration, login, and forgot-password screens.
- Role dashboards for Admin, Site Supervisor, and Contractor.
- Admin school/site management.
- Admin supervisor access assignment per site.
- Category settings.
- Supervisor site visit flow with camera/gallery photo capture.
- Work item assignment to contractors.
- Contractor status updates and after-photo upload.
- Supervisor verification and rejection flow.
- Demo report-generation placeholder.

The current app uses in-memory demo data so it is easy to run locally. A backend,
database, auth service, cloud storage, and PDF service can be connected next.

## Demo logins

Any password works in this MVP.

- Admin: `9999999999`
- Site Supervisor: `8888888888`
- Contractor: `6666666666`

## Run locally

This machine's Flutter SDK is at:

```sh
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter
```

Because this macOS user cannot write to `~/.config/flutter`, run Flutter commands
from this project with local config/cache paths:

```sh
cd "/Users/salonisingla/Desktop/freelance/Android app"
export XDG_CONFIG_HOME="$PWD/.config"
export PUB_CACHE="$PWD/.pub-cache"
```

Install dependencies:

```sh
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter pub get
```

Preview immediately in Chrome:

```sh
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter run -d chrome
```

Or use the helper script, which sets the required local Flutter config paths:

```sh
./run_chrome.sh
```

Run on Android after Android Studio/Android SDK is installed:

```sh
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter doctor
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter run -d android
```

Build a debug APK:

```sh
/Users/salonisingla/Desktop/freelance/flutter/bin/flutter build apk --debug
```
