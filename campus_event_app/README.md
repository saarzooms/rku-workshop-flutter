# Campus Event & Attendance System (Flutter + Riverpod Client)

Production-grade cross-platform mobile & web client built with **Flutter 3.x** and **Riverpod** state management, communicating with the PHP 8 REST API and MySQL database.

---

## 🚀 Checkpoint: Sprints 3 & 4 (Full-Stack Integration)

At this checkpoint, the client is fully wired to the backend API:
- **Authentication**: JWT/Bearer Token handling stored via `flutter_secure_storage`
- **State Management**: Reactive `Notifier` & `AsyncNotifier` with Riverpod
- **Event Management**: Live event feeds, detail screens, search & filter, event creation
- **Registrations**: One-click RSVP, capacity enforcement, cancellation, and ticket listings

---

## 🛠️ Running the Application

### 1. Ensure Backend is Running
In a separate terminal:
```bash
cd campus_event_api
php -S 127.0.0.1:8000 -t public
```

### 2. Run Flutter App
- **Android Emulator**:
  ```bash
  flutter run
  ```
  *(Default base URL automatically points to `http://10.0.2.2:8000`)*

- **Chrome / Web**:
  ```bash
  flutter run -d chrome
  ```

- **Physical Android Device**:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:8000
  ```

---

## 🧪 Testing

Run test suite:
```bash
flutter test --concurrency=1
```

Run static analysis:
```bash
flutter analyze
```
