# WorkFlow App

A Flutter project and task management application that helps users organize projects, manage tasks, track progress, add comments, attach local images, and work with both local and cloud-backed data.

## Features

- Email and password authentication using Firebase Authentication
- User session gate: authenticated users enter the app; signed-out users see the login screen
- Create and manage projects
- View project details and project-specific task lists
- Create tasks with title, description, priority, due date, and status
- Edit and delete tasks
- Mark tasks as completed
- Search tasks by title or task content
- Filter tasks by status, priority, or other available criteria
- Add comments to tasks
- Local task image attachments selected from the device gallery
- Attachment metadata persistence with SQLite
- Cloud Firestore integration for task and comment data
- SQLite local persistence for offline-friendly data access
- Pending synchronization structure for changes made while offline
- Network status banner and connectivity detection
- Firebase Cloud Messaging permission handling and FCM device-token generation

## Screens

The application includes the following main screens:

- Authentication screen
- Project list screen
- Project details screen
- Task create and edit form
- Task details screen
- Comment section
- Local attachment section
- Network status indicator

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Authentication |
| Cloud database | Cloud Firestore |
| Local database | SQLite |
| Notifications | Firebase Cloud Messaging |
| Image selection | `image_picker` |
| Connectivity | Flutter connectivity service |
| State/UI | Flutter Material widgets |

## Architecture

The project uses a feature-oriented structure and separates reusable infrastructure from feature code.

```text
lib/
├── core/
│   ├── auth/
│   │   └── auth_service.dart
│   ├── cloud/
│   │   └── firestore_service.dart
│   ├── database/
│   │   └── app_database.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── connectivity_service.dart
│   ├── notifications/
│   │   └── notification_service.dart
│   └── sync/
│       ├── sync_operation.dart
│       └── sync_service.dart
├── features/
│   ├── attachments/
│   ├── auth/
│   ├── comments/
│   └── tasks/
├── shared/
│   └── widgets/
│       └── network_status_banner.dart
├── firebase_options.dart
└── main.dart
```

## Local Attachments

Users can select task images from their device gallery. The app stores the image path and attachment metadata locally using SQLite and displays a preview inside the relevant task.

This version intentionally uses **local-only attachments**. Firebase Storage is not enabled because the project is designed to avoid requiring a Firebase Blaze billing account.

## Notifications

The app initializes Firebase Cloud Messaging and requests notification permission from the user. It retrieves an FCM registration token for the installed device and can receive Firebase Console test notifications.

Automatic due-date reminders are planned as future work because they require either:

- A secure backend or Cloud Functions to send remote notifications, or
- Device-side scheduled local notifications.

## Firebase Setup

This project uses Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging.

### Prerequisites

- Flutter SDK installed
- Android Studio or VS Code with Flutter support
- Firebase project
- Firebase CLI
- FlutterFire CLI

### Configure Firebase

1. Log in to Firebase:

```bash
firebase login
```

2. Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

3. From the project root, configure Firebase:

```bash
flutterfire configure
```

4. Install project dependencies:

```bash
flutter pub get
```

5. Run the app:

```bash
flutter run
```

FlutterFire generates Firebase configuration for Flutter projects through `flutterfire configure`; Firebase’s Flutter setup documentation describes using the Firebase CLI and FlutterFire CLI for this workflow. [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)

## Firestore Security Rules

If your Firestore data is stored under:

```text
users/{userId}/...
```

you can use owner-based rules so each user accesses only their own documents:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

Verify that these paths match your actual Firestore collection structure before publishing the rules.

## Quality Checks

Format the project:

```bash
dart format lib test
```

Run static analysis:

```bash
flutter analyze
```

Run automated tests:

```bash
flutter test
```

Run the application:

```bash
flutter run
```

## Build Android APK

Create a release APK:

```bash
flutter build apk --release
```

The generated file is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For smaller device-specific APK files:

```bash
flutter build apk --split-per-abi
```

Flutter’s Android deployment documentation describes release APK and split-per-ABI builds. [Flutter Android deployment](https://docs.flutter.dev/deployment/android)

## Manual Test Checklist

Before release, verify:

```text
[ ] User can register or log in.
[ ] User can create a project.
[ ] User can create a task.
[ ] User can edit task information.
[ ] User can delete a task.
[ ] User can search and filter tasks.
[ ] User can add a comment.
[ ] User can select and view a local image attachment.
[ ] Task and attachment data remain visible after restarting the app.
[ ] User can log out and log in again.
[ ] Firebase notification permission is requested.
[ ] An FCM device token is generated.
[ ] App passes flutter analyze.
[ ] Release APK builds successfully.
```

## Future Improvements

- Cloud attachment uploads using Firebase Storage or Amazon S3
- Scheduled local notifications for task due dates
- Server-triggered deadline reminders using Cloud Functions or a backend
- Store and rotate FCM tokens in Firestore
- Notification tap navigation to the relevant task
- Task reminders, recurring tasks, and calendar view
- Team collaboration and project member roles
- Task assignment to other users
- Dark mode
- Search improvements and advanced filtering
- Unit, widget, and integration test coverage

## Author

**[Nivetha]**

- GitHub: [Your GitHub profile](https://github.com/Nivetha002)
