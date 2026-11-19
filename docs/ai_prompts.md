# Reusable AI Coding Prompts
## Responsible AI-Assisted Development Guide

> **Golden Rule**: Never blindly paste AI-generated code. Always inspect existing files first, review generated code for security and architecture compliance, run `flutter analyze` / `php -l`, and test every path.

---

## 1. Generate a Flutter Feature Folder
**Prompt:**
> Inspect `campus_event_app/lib/features/` to match our MVVM + Repository structure. Create a new feature folder `campus_event_app/lib/features/<feature_name>/` with `models/`, `services/`, `repositories/`, `viewmodels/`, and `views/` subdirectories. Do not modify unrelated features. Follow Dart null-safety and Material 3 conventions.

## 2. Generate a Dart Model Class
**Prompt:**
> Inspect `campus_event_app/lib/features/events/models/event_model.dart`. Using the exact same pattern, create an immutable `<ModelName>` class in `campus_event_app/lib/features/<feature>/models/` with `final` fields, a `const` constructor, `factory <ModelName>.fromJson(Map<String, dynamic> json)`, and `Map<String, dynamic> toJson()`. Handle nullable fields safely without dynamic casts. Do not modify other files.

## 3. Generate an API Service Class
**Prompt:**
> Inspect `campus_event_app/lib/core/network/api_client.dart`. Create `<Feature>Service` in `campus_event_app/lib/features/<feature>/services/` that accepts `ApiClient` via constructor injection. Implement methods for `<endpoints>`. Parse responses using `ApiResponse` and let `ApiException` propagate cleanly. Do not put UI state or `BuildContext` inside the service.

## 4. Generate a Repository Class
**Prompt:**
> Inspect `campus_event_app/lib/features/events/repositories/event_repository.dart`. Create `<Feature>Repository` in `campus_event_app/lib/features/<feature>/repositories/` wrapping `<Feature>Service` and converting JSON maps into typed Dart models. Do not modify unrelated repositories.

## 5. Generate a ViewModel (`Notifier` / Riverpod)
**Prompt:**
> Inspect `campus_event_app/lib/features/events/viewmodels/event_viewmodel.dart`. Create an immutable `<Feature>State` class with `copyWith()` and `<Feature>ViewModel extends Notifier<<Feature>State>` exposed via `NotifierProvider`. Wrap async repository calls in `try/catch` and update `state` cleanly. Never make direct `http` calls inside the ViewModel.

## 6. Generate Reusable Widgets
**Prompt:**
> Inspect `campus_event_app/lib/core/widgets/`. Create a reusable Material 3 widget `<WidgetName>` in `campus_event_app/lib/core/widgets/` with `const` constructor, clear parameter types, semantic accessibility labels, and responsive padding. Do not embed business logic or API calls.

## 7. Generate a Flutter Form with Validation
**Prompt:**
> Inspect `campus_event_app/lib/features/auth/views/login_screen.dart`. Create a `StatefulWidget` form screen using `GlobalKey<FormState>`, `TextEditingController`s (disposed in `dispose()`), client-side validators, loading button state, and `SnackBar` feedback on success/error. Delegate submission to the ViewModel.

## 8. Generate PHP CRUD Endpoints
**Prompt:**
> Inspect `campus_event_api/app/Controllers/EventController.php` and `EventRepository.php`. Create `<Resource>Repository` using PDO prepared statements and `<Resource>Controller` using `Response::ok()`, `Response::error()`, and `Validator::requireFields()`. Enforce role checks via `AuthMiddleware::requireAuth([...])` in `routes/api.php`. Never trust client-supplied `user_id` or `role`.

## 9. Generate MySQL Schema & Seed Data
**Prompt:**
> Inspect `campus_event_api/database/database.sql`. Write a normalized MySQL table definition for `<table_name>` with `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`, `FOREIGN KEY` constraints, `UNIQUE` indexes for duplicate prevention, and `created_at` / `updated_at` timestamps using `InnoDB` and `utf8mb4`.

## 10. Generate Postman / API Test Cases
**Prompt:**
> Inspect `docs/api_documentation.md` and `postman/campus_event_api.postman_collection.json`. Generate positive and negative test cases (valid input, 422 validation error, 401 unauthorized, 403 forbidden, 409 conflict) for `<endpoint>`.

## 11. Generate Unit Tests (Dart)
**Prompt:**
> Inspect `campus_event_app/test/`. Write `flutter_test` unit tests for `<ModelOrViewModel>` verifying `fromJson` parsing, state transitions (`isLoading`, error handling), and edge cases without hitting a live network.

## 12. Generate Widget Tests (Dart)
**Prompt:**
> Inspect `campus_event_app/test/widget_test.dart`. Write a `testWidgets` test for `<ScreenName>` pumping `MaterialApp` with mocked/fake ViewModels, verifying initial rendering, form validation errors, and button interactions.

## 13. Generate Documentation Updates
**Prompt:**
> Inspect the actual implementation in `campus_event_app/` and `campus_event_api/` and update `docs/api_documentation.md` or `docs/campus_event_codelab.html` so that every file path, symbol name, and endpoint matches the codebase 100%.
