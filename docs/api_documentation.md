# REST API Documentation
## Campus Event & Attendance Management System

Base URL (Local Development): `http://localhost:8000/api` (Android Emulator: `http://10.0.2.2:8000/api`)

## Response Envelope

### Success
```json
{
  "success": true,
  "message": "Operation completed",
  "data": {}
}
```

### Error
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": "Valid email address is required"
  }
}
```

---

## 1. Authentication

### `POST /api/auth/register`
- **Auth**: Public | **Role**: Any (registers as `student` by default; `role` in body is ignored for security).
- **Request**: `{"full_name": "Aarav Patel", "email": "aarav@campus.edu", "password": "Password123!", "student_id_number": "24CS001", "department": "Computer Engineering"}`
- **201 Created**: `{"success": true, "message": "Registration successful", "data": {"token": "...", "user": {...}}}`
- **409 / 422**: Duplicate email or validation errors.

### `POST /api/auth/login`
- **Auth**: Public
- **Request**: `{"email": "aarav@campus.edu", "password": "Password123!"}`
- **200 OK**: `{"success": true, "message": "Login successful", "data": {"token": "...", "expires_at": "2026-11-19 12:00:00", "user": {...}}}`
- **401 Unauthorized**: Invalid credentials.

### `POST /api/auth/logout`
- **Auth**: Bearer Token required
- **200 OK**: `{"success": true, "message": "Logged out successfully", "data": null}`

---

## 2. Events

### `GET /api/events`
- **Auth**: Optional (Public returns `published` events; Organizer/Admin can filter all).
- **Query Params**: `search`, `category_id`, `status`
- **200 OK**: `{"success": true, "message": "Events retrieved", "data": {"events": [...]}}`

### `GET /api/events/{id}`
- **Auth**: Optional (Authenticated users also receive `is_registered` boolean).
- **200 OK**: `{"success": true, "message": "Event retrieved", "data": {"event": {...}}}`
- **404 Not Found**: Event does not exist.

### `POST /api/events`
- **Auth**: Bearer Token | **Role**: `organizer`, `admin`
- **Request**: `{"title": "Flutter Workshop", "description": "...", "category_id": 1, "venue": "Auditorium A", "start_time": "2026-12-01 10:00:00", "end_time": "2026-12-01 16:00:00", "max_capacity": 120}`
- **Validation**: `title` required, `end_time > start_time`, `max_capacity > 0`, `category_id` exists.
- **201 Created**: `{"success": true, "message": "Event created", "data": {"event": {...}}}`

### `PUT /api/events/{id}`
- **Auth**: Bearer Token | **Role**: `organizer` (owner only), `admin`
- **200 OK**: `{"success": true, "message": "Event updated", "data": {"event": {...}}}`
- **403 Forbidden**: Organizer does not own the event.

### `DELETE /api/events/{id}`
- **Auth**: Bearer Token | **Role**: `organizer` (owner only), `admin`
- **200 OK**: `{"success": true, "message": "Event cancelled", "data": null}`

---

## 3. Event Registrations

### `POST /api/events/{id}/register`
- **Auth**: Bearer Token | **Role**: `student` (or any authenticated user)
- **201 Created**: `{"success": true, "message": "Registered for event", "data": {"registration": {...}}}`
- **409 Conflict**: Already registered or event at full capacity.
- **400 Bad Request**: Event is not published or already ended.

### `DELETE /api/events/{id}/register`
- **Auth**: Bearer Token
- **200 OK**: `{"success": true, "message": "Registration cancelled", "data": null}`
- **400 Bad Request**: Cannot cancel after event has started.

### `GET /api/my-registrations`
- **Auth**: Bearer Token
- **200 OK**: `{"success": true, "message": "Registrations retrieved", "data": {"registrations": [...]}}`

---

## 4. QR Attendance

### `POST /api/events/{id}/attendance/qr`
- **Auth**: Bearer Token | **Role**: `organizer` (owner), `admin`
- **Request**: `{"ttl_minutes": 15}` (optional, default 15, max 120)
- **201 Created**: `{"success": true, "message": "QR token generated", "data": {"qr_token": "...", "expires_at": "..."}}`

### `POST /api/attendance/verify`
- **Auth**: Bearer Token | **Role**: `student`
- **Request**: `{"qr_token": "..."}`
- **201 Created**: `{"success": true, "message": "Attendance recorded", "data": {"attendance": {...}}}`
- **400 / 403 / 409**: Invalid/expired token, student not registered, or attendance already recorded.

### `GET /api/events/{id}/attendance`
- **Auth**: Bearer Token | **Role**: `organizer` (owner), `admin`
- **200 OK**: `{"success": true, "message": "Attendance report retrieved", "data": {"summary": {...}, "attendees": [...]}}`

### `GET /api/my-attendance`
- **Auth**: Bearer Token
- **200 OK**: `{"success": true, "message": "My attendance retrieved", "data": {"attendance": [...]}}`

---

## 5. Notifications & Profile

### `POST /api/notifications/device-token`
- **Auth**: Bearer Token
- **Request**: `{"fcm_token": "...", "platform": "android"}`
- **200 OK**: `{"success": true, "message": "Device token saved", "data": null}`

### `POST /api/notifications/send`
- **Auth**: Bearer Token | **Role**: `organizer` (event owner), `admin`
- **Request**: `{"event_id": 1, "title": "Room Change", "body": "Moved to Hall B"}`
- **200 OK**: `{"success": true, "message": "Notification queued/sent", "data": {"recipient_count": 42}}`

### `GET /api/profile` & `PUT /api/profile`
- **Auth**: Bearer Token
- **200 OK**: Returns or updates `full_name`, `student_id_number`, `department`, `phone`.

### Admin & Category Endpoints (Supporting MVP Admin & Discovery)
- `GET /api/categories` (Public)
- `POST /api/categories` (`admin`)
- `GET /api/admin/stats` (`admin`)
- `GET /api/admin/users` (`admin`)
- `PATCH /api/admin/users/{id}/status` (`admin`)
- `PATCH /api/admin/events/{id}/status` (`admin` — approve/reject events)
