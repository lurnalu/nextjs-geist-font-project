# Cherish Orthopaedic Centre EHR App

A multi-platform Electronic Health Records (EHR) application for Cherish Orthopaedic Centre, supporting both Windows and Android platforms.

## Features

- Patient Management
- Appointment Scheduling
- Email & SMS Notifications via Brevo API
- Marketing Campaigns
- Cross-platform Support (Windows & Android)

## Prerequisites

- Flutter SDK (latest stable version)
- Windows 10 or later
- Android SDK Command-line Tools
- Android NDK
- PostgreSQL (for Windows version)
- Brevo API Account

## Quick Start

1. **Clone and Install Dependencies**
```bash
git clone <repository-url>
cd cherish_ehr_app
flutter pub get
```

2. **Configure Environment**
Create `.env` file:
```env
BREVO_API_KEY=your_api_key_here
SMTP_HOST=smtp-relay.brevo.com
SMTP_PORT=587
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
```

## Build Instructions

### Android Build (Command Line)

```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Install on connected device
flutter install
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Windows Build

```bash
# Enable Windows desktop support
flutter config --enable-windows-desktop

# Build debug version
flutter run -d windows

# Build release version
flutter build windows --release
```

Windows executable location: `build/windows/runner/Release/`

## Database Setup

### Windows (PostgreSQL)
```sql
CREATE DATABASE cherish_ehr;
CREATE USER your_username WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE cherish_ehr TO your_username;
```

### Android
SQLite database is automatically configured and created on first run.

## Release Preparation

### Android Release Signing
1. Generate key:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure signing:
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Windows Release Distribution
1. Copy from `build/windows/runner/Release/`:
   - Main executable
   - All DLL files
   - data/ directory
2. Optional: Create installer using preferred tool

## Troubleshooting

### Build Issues
```bash
# Clean build files
flutter clean

# Get dependencies again
flutter pub get

# Check Flutter installation
flutter doctor
```

### Database Issues
- Verify PostgreSQL service is running (Windows)
- Check database credentials
- Ensure proper permissions

### Email/SMS Issues
- Verify Brevo API credentials in .env
- Check internet connectivity
- Verify service initialization in logs

## Support

For technical issues:
- Check Flutter logs: `flutter logs`
- Review database logs
- Contact system administrator

## License

[Add License Information]
