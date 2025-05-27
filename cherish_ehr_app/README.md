# Cherish Orthopaedic Centre EHR App

A multi-platform Electronic Health Record (EHR) app built with Flutter and Dart for managing Cherish Orthopaedic Centre clinic business in Nanyuki, Kenya.

## Platforms Supported

- Windows Desktop
- Android Mobile

## Features

- Modern hospital-themed UI/UX
- Login and Sign-up screens with clinic logo
- Local data storage using PostgreSQL (Windows) and SQLite (Android)
- Patient management, appointments, and medical records (to be implemented)

## Getting Started

### Prerequisites

- Flutter SDK installed: https://flutter.dev/docs/get-started/install
- For Windows desktop support, enable desktop support in Flutter.
- Android SDK and emulator or physical device for Android testing.

### Setup

1. Clone the repository.

2. Add your clinic logo image:

   Place your clinic logo image as `logo.png` inside the `assets` folder:

   ```
   cherish_ehr_app/assets/logo.png
   ```

3. Get dependencies:

   ```
   flutter pub get
   ```

4. Generate app icons for Android and Windows using flutter_launcher_icons:

   ```
   flutter pub run flutter_launcher_icons:main
   ```

### Running the App

- To run on Windows desktop:

  ```
  flutter run -d windows
  ```

- To run on Android device or emulator:

  ```
  flutter run -d android
  ```

## Database

- On Windows, the app will connect to a local PostgreSQL database. Ensure PostgreSQL is installed and running.
- On Android, the app uses SQLite via the `sqflite` package for local storage.

## Notes

- This is an initial version with login and signup UI.
- Further development is needed to implement full EHR features.

## License

This project is for Cherish Orthopaedic Centre and is not open source.
