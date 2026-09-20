# Presentra Mobile

<p align="center">
  <img src="assets/images/logo_presentra.png" alt="Presentra logo" width="240" />
</p>

<p align="center">
  A Flutter mobile client for Presentra, a role-based QR attendance and school management platform.
</p>

## Overview

Presentra Mobile helps schools manage daily attendance workflows from a single mobile application. It connects to the Presentra REST API and Firebase services to provide authenticated, role-specific experiences for teachers and school staff.

The app uses Firebase Authentication for sign-in, Firebase Cloud Messaging for push notifications, and Firebase ID tokens to authenticate requests to the backend API.

## Features

| Role | Capabilities |
| --- | --- |
| **Teacher** | View teaching schedules, monitor daily attendance, scan classroom QR codes, review attendance history, and access assigned duty schedules. |
| **Guidance Counselor (BK)** | View attendance statistics, monitor students with frequent absences, review recap reports, filter reporting periods, and export reports to Excel. |
| **Class Secretary** | View class attendance summaries, record student attendance, inspect student details, and review attendance history by date range. |
| **Duty Staff** | Monitor attendance completion across classes, filter class status, and inspect detailed class attendance. |

Shared application features include:

- Firebase email/password authentication.
- Role-based navigation and dashboards.
- QR code attendance scanning with camera permission handling.
- Push notifications and local notification display.
- Automatic Firebase token refresh and expired-session handling.
- Light and dark themes that follow the system appearance.
- Network, server, and authentication error states with retry flows.

## Presentra Ecosystem

Presentra is split into separate clients and services:

| Repository | Description |
| --- | --- |
| [presentra-mobile](https://github.com/Myankoi/presentra_mobile) | Flutter mobile client for teachers and school staff. |
| [presentra-web](https://github.com/Myankoi/presentra-web) | React-based admin dashboard for managing users, classes, students, schedules, reports, and notifications. |
| [presentra-api](https://github.com/Myankoi/presentra-api) | Shared backend REST API used by the mobile and web applications. |

The mobile and web applications share the same backend API and Firebase project. User roles and permissions are enforced across the connected services.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State management:** Provider
- **Authentication:** Firebase Authentication
- **Push notifications:** Firebase Cloud Messaging and `flutter_local_notifications`
- **Networking:** Dart `http` package and REST API
- **QR scanning:** `mobile_scanner`
- **Local storage:** `shared_preferences`
- **Utilities:** `intl`, `google_fonts`, `path_provider`, and `open_filex`

## Project Structure

```text
lib/
├── core/
│   ├── constants/       # API configuration
│   ├── errors/          # Application failure types
│   ├── network/         # Authenticated HTTP client
│   ├── services/        # Push notification services
│   ├── theme/           # Theme and design tokens
│   └── utils/           # Shared utilities
├── features/
│   ├── auth/            # Authentication and user session
│   ├── bk/              # Guidance counselor dashboard and reports
│   ├── guru/            # Teacher dashboard, schedules, and QR scanning
│   ├── notification/    # Notification inbox
│   ├── piket/           # Duty monitoring dashboard
│   ├── profil/          # User profile
│   └── sekretaris/      # Class secretary attendance workflows
├── shared/
│   ├── models/          # Shared data models
│   ├── utils/           # Shared UI utilities
│   └── widgets/         # Reusable widgets
└── main.dart            # Application entry point and route registration
```

Feature modules generally keep their data sources, domain logic, state providers, and presentation screens close together so each role-specific workflow can evolve independently.

## Requirements

- Flutter SDK with Dart SDK `^3.8.1` support.
- Android SDK with minimum API level 23 for Android builds.
- Xcode and CocoaPods for iOS development.
- A Firebase project configured for the application.
- A running and reachable instance of [presentra-api](https://github.com/Myankoi/presentra-api).
- A physical device or emulator. Camera-based QR scanning requires camera access.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Myankoi/presentra_mobile.git
cd presentra_mobile
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The application initializes Firebase on startup and expects platform-specific Firebase configuration.

Using the FlutterFire CLI is the recommended setup method:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select the Firebase project shared by the Presentra services. Enable Email/Password authentication and configure Firebase Cloud Messaging for the target platform. The configuration command generates `lib/firebase_options.dart` and the required platform configuration files.

Do not commit private service-account keys, signing keys, or environment-specific credentials.

### 4. Configure the backend API

Set the backend host in [`lib/core/constants/api_config.dart`](lib/core/constants/api_config.dart):

```dart
static const String baseUrl = 'https://your-api-host.example.com';
```

The app adds the `/api` prefix to this base URL. The API must be reachable from the device or emulator and must use the same Firebase project for token verification.

For local development, use a host address that is reachable from the selected device or emulator instead of assuming that `localhost` refers to the development machine.

### 5. Run the application

```bash
flutter run
```

Users must already be provisioned in the Presentra system with an appropriate role. Account and administrative management is handled through the Presentra web dashboard and backend services.

## Development Commands

```bash
# Analyze the project
flutter analyze

# Run tests
flutter test

# Build a release APK
flutter build apk --release

# Build an iOS release (requires macOS and Xcode)
flutter build ios --release
```

## Authentication and API Flow

1. A user signs in with Firebase Authentication.
2. The mobile app obtains a Firebase ID token and synchronizes the device's FCM token with the API.
3. The app fetches the authenticated user's profile and role from the API.
4. Subsequent API requests include the Firebase token as a Bearer token.
5. Expired tokens are refreshed once automatically. If the session remains unauthorized, the app clears the local session and returns the user to the login screen.

## Notes

- The API base URL is currently configured in source code rather than a runtime environment file.
- Push notifications require platform-specific notification permissions and Firebase messaging configuration.
- QR attendance requires camera permission and a valid classroom QR code.
- The mobile client is intended for teacher and school-staff workflows; administrative management is provided by [presentra-web](https://github.com/Myankoi/presentra-web).

## License

No license has been published for this repository yet.

## Related Links

- [Presentra Web](https://github.com/Myankoi/presentra-web)
- [Presentra API](https://github.com/Myankoi/presentra-api)
