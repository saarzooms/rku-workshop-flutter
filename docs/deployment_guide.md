# Deployment Guide
## Campus Event & Attendance Management System

## Scenario A: Local Development

### 1. MySQL Database
1. Start MySQL (via XAMPP Control Panel or local MySQL service).
2. Import the schema and sample data:
   ```bash
   mysql -u root -p < campus_event_api/database/database.sql
   ```

### 2. PHP Backend
```bash
cd campus_event_api
composer install
cp .env.example .env
php -S 0.0.0.0:8000 -t public
```
> Only `public/` is exposed as the document root so `.env`, `app/`, and `storage/` remain inaccessible over HTTP.

### 3. Flutter Mobile App
- **Android Emulator**: Default `ApiConstants.baseUrl` is `http://10.0.2.2:8000`, which automatically maps to your host machine's `localhost:8000`.
- **Physical Android Device**: Connect phone and PC to the same Wi-Fi, find your PC's LAN IP (e.g. `192.168.1.42`), and run:
  ```bash
  cd campus_event_app
  flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000
  ```

---

## Scenario B: Production Deployment

### 1. PHP Backend & MySQL (VPS / cPanel / Cloud)
1. Provision a MySQL 8+ database and dedicated non-root database user.
2. Import `campus_event_api/database/database.sql` (remove or change passwords of seeded accounts immediately).
3. Point your Apache/Nginx VirtualHost `DocumentRoot` to `/var/www/campus_event_api/public`.
4. Configure `.env` with `APP_ENV=production`, `APP_DEBUG=false`, and production DB credentials.
5. Enable **HTTPS** (Let's Encrypt / Certbot). Never send bearer tokens over plain HTTP in production.

### 2. Firebase Cloud Messaging (FCM)
1. Create a Firebase Project and register your Android app (`edu.campus.campus_event_app`).
2. Download `google-services.json` into `campus_event_app/android/app/google-services.json` (excluded from Git).
3. In Firebase Console -> **Project Settings -> Service Accounts**, generate a private key JSON and place it **outside** `public/` (e.g. `campus_event_api/storage/firebase-service-account.json`).
4. Set `FCM_PROJECT_ID` and `FCM_SERVICE_ACCOUNT_PATH` in `campus_event_api/.env`.

### 3. Android Release Signing, APK & AAB
1. Generate an upload keystore (keep it secret, never commit it):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Configure `campus_event_app/android/key.properties` and `android/app/build.gradle.kts` signingConfigs.
3. Build release artifacts pointing to your HTTPS production API:
   ```bash
   cd campus_event_app
   flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.edu
   flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.edu
   ```
   - APK output: `build/app/outputs/flutter-apk/app-release.apk`
   - AAB output (for Google Play Console): `build/app/outputs/bundle/release/app-release.aab`
