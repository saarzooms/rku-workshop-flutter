# Testing Guide & Verification Checklist
## Campus Event & Attendance Management System

## 1. Automated Flutter Tests (`flutter test`)

Run static analysis and unit/widget tests:
```bash
cd campus_event_app
flutter analyze
flutter test
```

### Covered Scenarios in `test/widget_test.dart`
- `UserModel.fromJson` role parsing (`student`, `organizer`, `admin`).
- `EventModel.fromJson` capacity & `isFull` computation.
- `EventCard` rendering and tap callback.
- `LoginScreen` client-side empty email/password validation.

---

## 2. Backend & API Testing Checklist (Postman)

Import `postman/campus_event_api.postman_collection.json` and `postman/local_environment.postman_environment.json`.

### Authentication
- [ ] **Valid login**: `POST /api/auth/login` with `student@campus.edu` / `Password123!` returns `200` + `token`.
- [ ] **Invalid password**: Returns `401 Unauthorized`.
- [ ] **Empty fields**: Returns `422 Validation failed` with `errors`.
- [ ] **Expired/missing token**: Calling `GET /api/my-registrations` without `Bearer` returns `401`.
- [ ] **Unauthorized role**: Calling `POST /api/events` as a `student` returns `403 Forbidden`.

### Events
- [ ] **Event listing**: `GET /api/events` returns published events.
- [ ] **Event details**: `GET /api/events/1` returns event with `registered_count`.
- [ ] **Event creation**: `POST /api/events` as `organizer@campus.edu` returns `201 Created`.
- [ ] **Event modification**: `PUT /api/events/{id}` by owner succeeds; by another organizer returns `403`.
- [ ] **Event deletion/cancellation**: `DELETE /api/events/{id}` marks event `cancelled`.
- [ ] **Invalid event data**: `end_time <= start_time` or `max_capacity <= 0` returns `422`.

### Registration
- [ ] **Successful registration**: `POST /api/events/1/register` returns `201`.
- [ ] **Duplicate registration**: Second `POST /api/events/1/register` returns `409 Conflict`.
- [ ] **Cancellation**: `DELETE /api/events/1/register` before start returns `200`.
- [ ] **Closed/ended event**: Registering for cancelled/ended event returns `400`.

### QR Attendance
- [ ] **Generate QR**: `POST /api/events/1/attendance/qr` as organizer returns `qr_token` + `expires_at`.
- [ ] **Valid QR**: `POST /api/attendance/verify` as registered student returns `201`.
- [ ] **Invalid QR**: Random token returns `400 Invalid attendance QR code`.
- [ ] **Expired QR**: Token past `expires_at` returns `400 Attendance QR code has expired`.
- [ ] **Unregistered student**: Returns `403 You must be registered for this event`.
- [ ] **Duplicate attendance**: Second scan returns `409 Attendance already recorded`.

### Push Notifications
- [ ] **Device token registration**: `POST /api/notifications/device-token` returns `200`.
- [ ] **Foreground notification**: SnackBar displays when app is open.
- [ ] **Background/tap navigation**: Tapping notification opens `/events/{event_id}`.
