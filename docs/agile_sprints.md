# Agile Development Plan & Sprints
## Campus Event & Attendance Management System

## 1. Agile Methodology Overview

- **Product Backlog**: Prioritized list of all user stories across Student, Organizer, and Admin roles.
- **Sprint Planning**: Breaking backlog items into concrete engineering tasks with clear **Acceptance Criteria**.
- **Definition of Done (DoD)**:
  1. Code adheres to MVVM + Repository (Flutter) or Controller + Repository (PHP).
  2. `flutter analyze` passes with zero errors.
  3. Unit/widget tests or API checks pass.
  4. Documentation and Codelab steps match the actual code.

---

## 2. Sprint Breakdown

| Sprint | Goal | Key Deliverables |
| :--- | :--- | :--- |
| **Sprint 0** | Project Planning & Design | SRS, Architecture & ER diagrams, API contract, Agile backlog (`docs/`). |
| **Sprint 1** | Flutter Setup & UI Foundation | `campus_event_app` created, Material 3 theme, `go_router` navigation, Auth & Dashboard UI prototypes. |
| **Sprint 2** | PHP Backend & MySQL Database | `campus_event_api`, `database.sql` schema + seed data, PDO, Router, Auth endpoints + role middleware. |
| **Sprint 3** | Event Management | Event CRUD APIs, Flutter Event models/repo/ViewModel, Event List, Detail, and Organizer Create/Edit screens. |
| **Sprint 4** | Event Registration | Registration & cancellation APIs with duplicate/capacity guards, My Registrations screen, loading/empty/error states. |
| **Sprint 5** | QR Code Attendance | Time-limited QR token generation (`qr_flutter`), scanning (`mobile_scanner`), server-side verification, attendance reports. |
| **Sprint 6** | Push Notifications (FCM) | `firebase_core` & `firebase_messaging`, device token API, PHP FCM HTTP v1 service, foreground/tap handling. |
| **Sprint 7** | Testing, Optimization & Deployment | Unit/widget/integration tests, Postman collection, release APK/AAB build guide, production deployment guide. |
