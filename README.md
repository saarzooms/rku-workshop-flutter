# Campus Event & Attendance Management System

A complete, beginner-friendly **8–10 hour workshop project** demonstrating how to design, build, test, and deploy a full-stack **Campus Event & Attendance Management System** with **Flutter**, **PHP 8**, **MySQL**, **QR Code Attendance**, and **Firebase Cloud Messaging (FCM)**.

## Start Here: Interactive Codelab
Open [`docs/campus_event_codelab.html`](docs/campus_event_codelab.html) in any web browser for the 14-chapter step-by-step Google Codelabs-style tutorial.

## Technologies
- **Mobile App**: Flutter 3.x (Material 3, `flutter_riverpod`, `go_router`, `http`, `flutter_secure_storage`, `qr_flutter`, `mobile_scanner`, `firebase_messaging`)
- **Backend**: PHP 8.x REST API (PDO prepared statements, opaque SHA-256 bearer tokens, role-based middleware)
- **Database**: MySQL 8.x / MariaDB
- **Push Notifications**: Firebase Cloud Messaging (HTTP v1)

## Project Structure
- [`campus_event_app/`](campus_event_app/) — Flutter Android application (MVVM + Repository architecture)
- [`campus_event_api/`](campus_event_api/) — PHP 8 REST API & `database/database.sql`
- [`docs/`](docs/) — Interactive HTML Codelab, SRS, System Design, ER Diagram, API Docs, Testing & Deployment guides
- [`postman/`](postman/) — Postman collection & local environment

## Git Branch Checkpoints (Beginner-Friendly Learning)

To make learning step-by-step and approachable for beginners, this repository is organized into dedicated checkpoint branches matching each sprint of the curriculum. You can switch between branches to inspect or run only the code implemented up to that milestone:

| Branch Name | Checkpoint / Sprint | Description & What's Included |
|---|---|---|
| [`01-planning-and-design`](https://github.com/saarzooms/rku-workshop-flutter/tree/01-planning-and-design) | Sprint 0 (Planning) | SRS Requirements, System Architecture, Database ER design, Agile plans, CI workflows, and documentation. *(No code yet)* |
| [`02-flutter-setup`](https://github.com/saarzooms/rku-workshop-flutter/tree/02-flutter-setup) | Sprint 1 (Setup) | Initial Flutter 3 project scaffold, Riverpod `ProviderScope`, Material 3 theme (`AppTheme`), basic routing, and smoke tests. |
| [`03-application-ui`](https://github.com/saarzooms/rku-workshop-flutter/tree/03-application-ui) | Sprint 1 (UI) | All UI screens: Login, Register, HomeShell, role tabs (Student/Organizer/Admin), Event list/detail/form, and My Registrations. |
| [`04-php-backend`](https://github.com/saarzooms/rku-workshop-flutter/tree/04-php-backend) | Sprint 2 (Backend) | PHP 8 REST API, MySQL `database.sql` schema, PDO repositories, controllers, bearer token middleware, and Postman collection. |
| [`05-flutter-php-integration`](https://github.com/saarzooms/rku-workshop-flutter/tree/05-flutter-php-integration) | Sprints 3 & 4 (Integration) | Full-stack Riverpod wiring: `ApiClient`, `AuthViewModel`, `EventViewModel`, `RegistrationViewModel`, and live API communication. |
| [`06-qr-attendance`](https://github.com/saarzooms/rku-workshop-flutter/tree/06-qr-attendance) | Sprint 5 (QR Attendance) | QR ticket generation (`qr_flutter`), mobile camera scanner (`mobile_scanner`), attendance verification API, and audit reports. |
| [`07-push-notifications`](https://github.com/saarzooms/rku-workshop-flutter/tree/07-push-notifications) | Sprint 6 (Push Alerts) | Firebase Cloud Messaging (FCM) push notification service, device token synchronization, and real-time event reminders. |
| [`master`](https://github.com/saarzooms/rku-workshop-flutter/tree/master) | Production Release | The complete codebase with automated GitHub Actions CI/CD workflows, unit/widget tests, and interactive HTML codelab. |

### How to Checkout a Specific Branch
```bash
# View all available checkpoint branches
git branch -a

# Checkout Sprint 1 Flutter Setup
git checkout 02-flutter-setup

# Checkout Sprint 2 PHP Backend
git checkout 04-php-backend

# Return to the complete production codebase
git checkout master
```

## Quick Setup
1. **Database**: Import `campus_event_api/database/database.sql` into MySQL.
2. **PHP API**:
   ```bash
   cd campus_event_api
   composer install
   cp .env.example .env
   php -S 0.0.0.0:8000 -t public
   ```
3. **Flutter App**:
   ```bash
   cd campus_event_app
   flutter pub get
   flutter run
   ```

## Default Development Accounts
All seeded accounts use password **`Password123!`** (change in production!):
- **Admin**: `admin@campus.edu`
- **Organizer**: `organizer@campus.edu`
- **Student**: `student@campus.edu`

## Documentation
- [Interactive Codelab Tutorial](docs/campus_event_codelab.html)
- [Requirements (SRS)](docs/requirements.md)
- [System Design & Architecture](docs/system_design.md)
- [Database Design & ER Diagram](docs/database_design.md)
- [REST API Documentation](docs/api_documentation.md)
- [Agile Sprints](docs/agile_sprints.md)
- [Testing Guide](docs/testing_guide.md)
- [Deployment Guide](docs/deployment_guide.md)
- [Reusable AI Prompts](docs/ai_prompts.md)
