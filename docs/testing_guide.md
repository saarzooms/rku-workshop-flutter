# Comprehensive Testing Guide & Verification Checklist
## Campus Event & Attendance Management System

This guide explains how to write, structure, and execute test cases across the entire software test pyramid: **Unit Tests**, **Widget/UI Tests**, and **Backend API Integration Tests**.

---

## 1. The Test Pyramid & The AAA Pattern

In enterprise software engineering, test cases are organized into three layers:

```
        / \
       /   \     Layer 3: End-to-End & API Integration Tests (Postman / CI)
      /-----\    Layer 2: Widget & Form Validation Tests (Flutter WidgetTester)
     /-------\   Layer 1: Unit Tests (Domain Models & Riverpod Logic)
```

Every test case follows the **AAA Pattern** (**Arrange** &rarr; **Act** &rarr; **Assert**):
1. **Arrange:** Set up test inputs, mock objects, or container states.
2. **Act:** Execute the code under test (run function, tap widget, or send HTTP request).
3. **Assert:** Validate that the actual results match the expected output (`expect(actual, expected)`).

---

## 2. Writing Test Cases for Different Scenarios

### Scenario 1: Unit Testing Domain Models & Business Logic

Unit tests run in milliseconds without requiring a phone emulator or live network. They verify JSON deserialization and business computations.

```dart
// test/unit/domain_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event_app/features/auth/models/user_model.dart';
import 'package:campus_event_app/features/events/models/event_model.dart';

void main() {
  group('Domain Models & Business Logic', () {
    test('UserModel.fromJson parses student role and attributes correctly', () {
      // 1. Arrange
      final json = {
        'id': 3,
        'full_name': 'Aarav Patel',
        'email': 'student@campus.edu',
        'role': 'student',
        'student_id_number': '24CE001',
        'department': 'Computer Engineering',
        'is_active': 1,
      };

      // 2. Act
      final user = UserModel.fromJson(json);

      // 3. Assert
      expect(user.id, 3);
      expect(user.fullName, 'Aarav Patel');
      expect(user.isStudent, isTrue);
      expect(user.isOrganizer, isFalse);
      expect(user.studentIdNumber, '24CE001');
    });

    test('EventModel.fromJson computes isFull = true when capacity is reached', () {
      final json = {
        'id': 1,
        'organizer_id': 2,
        'category_id': 1,
        'title': 'HackCampus 2026',
        'description': '24-hour hackathon',
        'venue': 'Innovation Lab',
        'start_time': '2026-12-05 09:00:00',
        'end_time': '2026-12-06 12:00:00',
        'max_capacity': 100,
        'registered_count': 100, // Full
        'status': 'published',
      };

      final event = EventModel.fromJson(json);

      expect(event.isFull, isTrue);
    });

    test('EventModel.fromJson computes isFull = false when seats remain', () {
      final json = {
        'id': 2,
        'organizer_id': 2,
        'category_id': 5,
        'title': 'Flutter Workshop',
        'description': 'Riverpod masterclass',
        'venue': 'Seminar Hall',
        'start_time': '2026-12-10 10:00:00',
        'end_time': '2026-12-10 16:00:00',
        'max_capacity': 60,
        'registered_count': 42, // 18 seats available
        'status': 'published',
      };

      final event = EventModel.fromJson(json);

      expect(event.isFull, isFalse);
    });
  });
}
```

---

### Scenario 2: Riverpod State & ViewModel Testing

Tests state transitions (e.g. `isLoading`, `currentUser`, `errorMessage`) using an isolated `ProviderContainer` without spinning up the UI.

```dart
// test/unit/auth_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_app/features/auth/viewmodels/auth_viewmodel.dart';

void main() {
  test('loginAsRole updates AuthState with user and marks isAuthenticated = true', () {
    // 1. Arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // 2. Act
    container.read(authViewModelProvider.notifier).loginAsRole('student');
    final state = container.read(authViewModelProvider);

    // 3. Assert
    expect(state.isAuthenticated, isTrue);
    expect(state.currentUser?.role, 'student');
    expect(state.currentUser?.email, 'student@campus.edu');
    expect(state.errorMessage, isNull);
  });
}
```

---

### Scenario 3: Widget UI & Form Validation Testing

Uses Flutter's `WidgetTester` to simulate user actions (entering text, tapping buttons, scrolling) and verify rendered text. We use `ProviderScope(overrides: [...])` to replace live API services with test fakes.

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event_app/core/widgets/event_card.dart';
import 'package:campus_event_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:campus_event_app/features/auth/views/login_screen.dart';
import 'package:campus_event_app/features/events/models/event_model.dart';

class _FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState(isInitialized: true);
}

void main() {
  group('Widget Tests', () {
    testWidgets('EventCard displays title, venue, and seat count', (tester) async {
      const event = EventModel(
        id: 1,
        organizerId: 2,
        categoryId: 1,
        title: 'Campus Hackathon',
        description: '24-hour coding challenge',
        venue: 'Innovation Lab',
        startTime: '2026-12-01 10:00:00',
        endTime: '2026-12-02 10:00:00',
        maxCapacity: 80,
        registeredCount: 25,
        status: 'published',
        categoryName: 'Technical',
      );

      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCard(
              event: event,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Campus Hackathon'), findsOneWidget);
      expect(find.text('Innovation Lab'), findsOneWidget);
      expect(find.text('25/80 seats'), findsOneWidget);

      await tester.tap(find.byType(EventCard));
      expect(tapped, isTrue);
    });

    testWidgets('LoginScreen displays required validation errors on empty submission',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(_FakeAuthViewModel.new),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
```

---

### Scenario 4: Backend REST API Status Codes & Edge Case Matrix

Import `postman/campus_event_api.postman_collection.json` and `postman/local_environment.postman_environment.json`. Assert each category:

| Test Scenario | Request Endpoint & Payload | Status Code | Assertion Rule |
|---|---|---|---|
| **Valid Login** | `POST /api/auth/login` (`student@campus.edu`) | `200 OK` | `data.token` exists; token is 64 hex chars. |
| **Invalid Password** | `POST /api/auth/login` (wrong password) | `401 Unauthorized` | `message: "Invalid credentials"` |
| **Empty Validation** | `POST /api/events` with missing `title` | `422 Unprocessable` | `errors.title` contains required error message. |
| **Chronological Error**| `POST /api/events` with `end_time <= start_time` | `422 Unprocessable` | `errors.end_time` explains invalid window. |
| **Unauthenticated** | `GET /api/my-registrations` without Bearer token | `401 Unauthorized` | Request rejected before database query. |
| **RBAC Violation** | `POST /api/events` executed by a `student` | `403 Forbidden` | `message: "Insufficient permissions"` |
| **Duplicate RSVP** | `POST /api/events/1/register` executed twice | `409 Conflict` | `message: "Already registered for this event"` |
| **Capacity Full** | `POST /api/events/{id}/register` on full event | `400 Bad Request` | `message: "Event has reached maximum capacity"` |
| **Invalid QR Token** | `POST /api/attendance/verify` with bogus string | `400 Bad Request` | `message: "Invalid attendance QR code"` |
| **Expired QR Token** | `POST /api/attendance/verify` with expired QR | `400 Bad Request` | `message: "Attendance QR code has expired"` |
| **Double Attendance**| `POST /api/attendance/verify` second scan | `409 Conflict` | `message: "Attendance already recorded"` |

#### Postman Test Script Assertion:
```javascript
pm.test("Status code is 201 Created", function () {
    pm.response.to.have.status(201);
});

pm.test("Registration returned with unique ticket code", function () {
    const json = pm.response.json();
    pm.expect(json.status).to.eql("success");
    pm.expect(json.data.registration).to.have.property("ticket_code");
    pm.expect(json.data.registration.registration_status).to.eql("registered");
});
```

---

## 3. How to Run Tests Locally

```bash
# 1. Run Flutter Static Analysis
cd campus_event_app
flutter analyze

# 2. Run All Automated Flutter Tests
flutter test --concurrency=1

# 3. Check PHP Syntax Across All Backend Files
cd ../campus_event_api
Get-ChildItem -Filter *.php -Recurse | ForEach-Object { php -l $_.FullName }
```

---

## 4. Continuous Integration (CI)

Every commit and Pull Request automatically triggers GitHub Actions workflows defined in:
* [`.github/workflows/flutter-ci.yml`](../.github/workflows/flutter-ci.yml)
* [`.github/workflows/php-backend-ci.yml`](../.github/workflows/php-backend-ci.yml)
