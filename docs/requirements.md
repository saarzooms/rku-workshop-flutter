# Software Requirements Specification (SRS)
## Campus Event & Attendance Management System

## 1. Project Overview

The **Campus Event & Attendance Management System** is a mobile-first platform designed for universities and colleges to streamline event publishing, student registration, and QR-code-based attendance tracking.

- **Target Platform**: Android (Flutter)
- **Backend**: PHP 8.x REST API
- **Database**: MySQL 8.x / MariaDB
- **Push Notifications**: Firebase Cloud Messaging (FCM HTTP v1)
- **Workshop Duration**: 8–10 hours (Agile incremental delivery)

---

## 2. User Roles & Capabilities

### 2.1 Student (`student`)
A student can:
1. Register a new account and log in with email and password.
2. View upcoming published campus events.
3. Search events by title, description, or venue.
4. Filter events by category.
5. View complete event details (date/time, venue, organizer, capacity, status).
6. Register for an open event (preventing duplicate registrations and over-capacity).
7. Cancel an active registration when permitted (before event start/closure).
8. View their registered events and registration status (`registered`, `cancelled`).
9. Receive push notifications for event updates and reminders.
10. Scan an organizer-displayed attendance QR code to record attendance.
11. View their personal attendance history and status.
12. View and update their personal profile.

### 2.2 Event Organizer (`organizer`)
An organizer can:
1. Log in to the organizer workspace.
2. View the organizer dashboard with summary metrics (total events, registrations, attendance).
3. Create new campus events (title, description, category, venue, start/end times, capacity).
4. Edit their own events.
5. Delete or cancel their own events.
6. View the list of students registered for their events and total registration counts.
7. Generate a time-limited, event-specific attendance QR token/code.
8. Validate student attendance via QR workflow.
9. View per-event attendance reports (present count, attendance rate, attendee list).
10. Send event-related push notifications to registered students.

### 2.3 Administrator (`admin`)
An administrator can:
1. View all events across the campus regardless of organizer.
2. Manage student accounts (view, activate/deactivate).
3. Manage organizer accounts (view, create/promote, activate/deactivate).
4. Manage event categories (create, update, list).
5. Approve or reject events (when approval workflow is enabled; status `pending_approval` -> `published` / `rejected`).
6. View overall campus-wide event statistics.
7. View attendance reports across all events.

> **Workshop MVP Note**: For the 8–10 hour workshop MVP, the Administrator role is implemented using a seeded admin account and a focused in-app Admin Dashboard. In a future production phase, a dedicated web-based admin portal can be built on top of the same REST API.

---

## 3. Functional Modules

| Module | Description |
| :--- | :--- |
| **Authentication** | Registration, login, logout, opaque bearer token issuance, SHA-256 token hashing, expiry, and revocation. |
| **User Management** | Role-based access control (`student`, `organizer`, `admin`), account status management. |
| **Event Management** | CRUD operations for events, category assignment, capacity tracking, status lifecycle (`draft`, `pending_approval`, `published`, `cancelled`, `completed`). |
| **Event Discovery** | Paginated/filtered event listing, keyword search, category filtering, event detail view. |
| **Event Registration** | One-click registration, capacity checks, duplicate prevention, cancellation, "My Registrations" view. |
| **QR Code Attendance** | Time-limited cryptographic attendance token generation by organizers, server-side QR verification and check-in by students. |
| **Attendance Reporting** | Per-event attendee lists, attendance percentages, and student personal attendance logs. |
| **Push Notifications** | FCM device token registration, PHP-to-FCM HTTP v1 dispatch, foreground/background handling, deep-link tap navigation. |
| **Profile Management** | View and edit user name, department, student/staff ID, and phone number. |

---

## 4. Non-Functional Requirements

1. **Maintainable Code**: Feature-based MVVM + Repository pattern in Flutter; layered MVC/Repository structure in PHP.
2. **Separation of Concerns**: UI widgets never make HTTP calls; ViewModels never parse raw DB rows; Backend controllers delegate persistence to repositories.
3. **Secure API Communication**: Bearer token authentication, HTTPS in production, no secrets in client code.
4. **Password Hashing**: `password_hash(..., PASSWORD_BCRYPT)` and `password_verify()` in PHP.
5. **Input Validation**: Server-side validation on every endpoint returning structured `422` errors; client-side form validation for UX.
6. **Error Handling**: Consistent JSON error envelopes (`success: false`, `message`, `errors`), typed exceptions in Flutter.
7. **Database Consistency**: Foreign keys, `UNIQUE` constraints (`(user_id, event_id)` on registrations, `(registration_id)` on attendance), transactions where needed.
8. **Duplicate Prevention**: Both database constraints and explicit application-level checks with clear HTTP `409 Conflict` responses.
9. **Responsive Mobile UI**: Material 3 design adapting cleanly to small and large Android screens.
10. **Loading Performance**: Lightweight JSON payloads, `ListView.builder` lazy rendering, loading/empty/error states.
11. **Basic Accessibility**: Semantic labels, sufficient contrast ratios, minimum 48dp touch targets, readable typography.
