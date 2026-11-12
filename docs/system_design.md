# System Design & Architecture
## Campus Event & Attendance Management System

## 1. High-Level Architecture

```mermaid
flowchart LR
    subgraph Mobile["Android Mobile App (Flutter)"]
        UI["Presentation Layer (Views & Widgets)"]
        VM["ViewModel Layer (ChangeNotifier / Provider)"]
        REPO["Repository Layer"]
        SVC["API & Storage Services (http, SecureStorage, FCM)"]
        UI --> VM --> REPO --> SVC
    end

    subgraph Backend["PHP 8 REST API (campus_event_api)"]
        RT["Router (routes/api.php)"]
        MW["Auth & Role Middleware"]
        CTRL["Controllers"]
        BSVC["Services (Auth, QR, FCM)"]
        BREPO["Repositories (PDO)"]
        RT --> MW --> CTRL --> BSVC --> BREPO
    end

    DB[("MySQL Database")]
    FCM["Firebase Cloud Messaging (FCM HTTP v1)"]

    SVC -- "HTTPS REST API (JSON + Bearer Token)" --> RT
    BREPO -- "PDO Prepared Statements" --> DB
    BSVC -- "OAuth2 Service Account + HTTP v1" --> FCM
    FCM -- "Push Notification" --> Mobile
```

### Key Architectural Decisions

1. **Why Flutter for the Frontend?**
   - Single codebase with fast Hot Reload, rich Material 3 widgets, strong typing with Dart, and mature packages for HTTP, secure storage, QR codes, and Firebase Messaging.
2. **Why PHP for the Backend?**
   - Ubiquitous, zero-friction setup (XAMPP / built-in PHP server), beginner-friendly procedural/OOP syntax, native `PDO` for MySQL, and simple deployment to shared hosting or VPS without heavy framework overhead.
3. **Why MySQL for Relational Data?**
   - Campus events, users, categories, registrations, and attendance are inherently relational. MySQL enforces referential integrity (`FOREIGN KEY`) and uniqueness (`UNIQUE KEY`) at the database engine level, preventing duplicate registrations and orphaned attendance records.
4. **Why REST API with JSON?**
   - Stateless, human-readable, platform-agnostic, and easy to inspect and test with Postman before writing a single line of Flutter networking code.
5. **Why Firebase ONLY for Push Notifications (in the default architecture)?**
   - MySQL + PHP already handle structured data, complex queries, and role-based authorization cleanly. Using Firebase solely for **Firebase Cloud Messaging (FCM)** avoids vendor lock-in and keeps all business rules in one authoritative PHP backend.
   - *Optional Alternatives*: Firebase Authentication or Cloud Firestore can replace PHP auth/MySQL in serverless architectures, but they are **not** dependencies here so beginners learn full-stack relational backend engineering.

---

## 2. Flutter Application Architecture (MVVM + Repository)

Each feature in `campus_event_app/lib/features/<feature>/` is organized into clear layers:

1. **Models (`models/`)**: Immutable Dart classes with `fromJson()` and `toJson()` factories.
2. **Services (`services/`)**: Thin classes calling `ApiClient` (`http`) or device plugins (`FlutterSecureStorage`, `FirebaseMessaging`). No UI state.
3. **Repositories (`repositories/`)**: Coordinate data fetching/caching and transform raw responses or exceptions into domain models.
4. **ViewModels (`viewmodels/`)**: Extend `ChangeNotifier` (via `provider`). Hold UI state (`isLoading`, `errorMessage`, data lists) and expose user actions (`loadEvents()`, `register()`). Never perform raw HTTP calls.
5. **Views (`views/`)**: Stateless/Stateful `Widget` screens that observe ViewModels via `context.watch<T>()` / `Consumer<T>()` and trigger actions via `context.read<T>()`.

---

## 3. Core Sequence Flows

### 3.1 Authentication Flow (Opaque Bearer Token)

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as PHP AuthController
    participant DB as MySQL (users, user_sessions)

    User->>App: Enter email & password, tap Login
    App->>API: POST /api/auth/login {email, password}
    API->>DB: SELECT user WHERE email = ?
    DB-->>API: User row (password_hash, role)
    API->>API: password_verify(password, password_hash)
    API->>API: Generate 32-byte random token + SHA-256 hash
    API->>DB: INSERT INTO user_sessions (user_id, token_hash, expires_at)
    API-->>App: 200 OK {token, user}
    App->>App: Save token in FlutterSecureStorage
    App-->>User: Navigate to Role Dashboard
```

### 3.2 QR Attendance Flow (Time-Limited Token)

```mermaid
sequenceDiagram
    actor Org as Organizer
    actor Stu as Student
    participant OrgApp as Organizer App
    participant StuApp as Student App
    participant API as PHP AttendanceController
    participant DB as MySQL

    Org->>OrgApp: Tap "Generate Attendance QR"
    OrgApp->>API: POST /api/events/{id}/attendance/qr
    API->>DB: Verify organizer owns event & event is published
    API->>DB: Store hashed QR token with 15-min expiry
    API-->>OrgApp: 200 OK {qr_payload, expires_at}
    OrgApp-->>Org: Display QR Code on screen

    Stu->>StuApp: Tap "Scan Attendance QR"
    StuApp->>StuApp: Scan QR -> extract qr_token
    StuApp->>API: POST /api/attendance/verify {qr_token}
    API->>DB: Validate token exists, not expired, event active
    API->>DB: Check student has active registration
    API->>DB: Check no existing attendance row
    API->>DB: INSERT INTO attendance (registration_id, marked_at)
    API-->>StuApp: 201 Created {attendance_record}
```

### 3.3 Push Notification Flow

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant FCM as Firebase Cloud Messaging
    participant API as PHP NotificationController
    participant DB as MySQL (device_tokens)

    App->>FCM: Request permission & getToken()
    FCM-->>App: FCM Device Token
    App->>API: POST /api/notifications/device-token {token, platform}
    API->>DB: Upsert into device_tokens

    Note over API,FCM: Later, Organizer sends event notification
    API->>DB: Fetch device_tokens for registered students
    API->>FCM: POST FCM HTTP v1 API (OAuth2 Bearer)
    FCM-->>App: Deliver push notification
```
