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
