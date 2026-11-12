# Campus Event & Attendance REST API (PHP 8)

## Quick Start

1. **Install Composer autoloader**:
   ```bash
   cd campus_event_api
   composer install
   ```
2. **Configure environment**:
   ```bash
   cp .env.example .env
   ```
   Update `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` in `.env`.
3. **Import MySQL schema & seed data**:
   ```bash
   mysql -u root -p < database/database.sql
   ```
4. **Run the built-in PHP development server** (exposing only `public/`):
   ```bash
   php -S 0.0.0.0:8000 -t public
   ```
5. **Verify**:
   Open `http://localhost:8000/api/health`.

## Development Accounts (Password: `Password123!`)
- **Admin**: `admin@campus.edu`
- **Organizer**: `organizer@campus.edu`
- **Student**: `student@campus.edu`
