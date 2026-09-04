---
name: flutter-app-development
description: Use this skill when building, modifying, reviewing, or structuring Flutter mobile applications. Follow the project's architecture, responsive layout rules, Cubit state management conventions, repository/service separation, API integration patterns, and code quality requirements.
---

# Flutter App Development Skill

## Purpose

Use this skill whenever working on a Flutter mobile application.

The goal is to keep Flutter projects:

- Structured
- Scalable
- Responsive
- Maintainable
- Consistent
- Easy to connect to a REST API backend

Do not change the project's established architecture unless explicitly requested.

---

## Architecture

Use:

`Feature-Based Layered Architecture`

The standard project structure should separate:

- App configuration
- Core shared code
- Models
- Data layer
- Features

Use:

`Cubit`

for state management.

Do not use Bloc Events unless the project explicitly requires Bloc instead of Cubit.

Use:

`Repository Pattern`

and:

`Services Layer`

The expected flow is:

`Screen`

↓

`Cubit`

↓

`Repository`

↓

`Service`

↓

`API Client`

↓

`REST API`

The UI must never call Dio, HTTP, or backend services directly.

The Cubit must not communicate directly with Dio or the REST API.

---

## State Management

Use:

`flutter_bloc`

with Cubit.

Each feature that requires state management should normally contain:

```text
cubit/
├── feature_cubit.dart
└── feature_state.dart
```

Keep Cubits focused on application state and user actions.

Do not place UI code inside Cubits.

Do not place direct API calls inside Cubits.

Prefer clear state definitions such as:

- initial
- loading
- success
- failure

Add additional states only when they represent meaningful UI states.

---

## Repository Layer

Repositories are responsible for providing application data to Cubits.

Repositories may:

- Fetch remote data from services
- Return temporary dummy data during development
- Convert API responses into models
- Handle data-source selection

Cubits should depend on repositories, not services.

This makes it possible to replace dummy data with a real backend without rewriting the UI or Cubits.

---

## Services Layer

Services are responsible for direct communication with external systems.

Examples:

- Authentication API
- Products API
- Orders API
- Booking API
- Profile API

Services may use:

`Dio`

for REST API requests.

Do not put UI logic or Cubit state logic inside services.

---

## Networking

For REST API projects, prefer:

`Dio`

Create a centralized API client.

The network layer should support:

- Base URL
- Timeouts
- Request headers
- Bearer token
- Interceptors
- Error handling
- Logging during development when useful

Do not hardcode API URLs throughout the application.

Store API paths in a centralized file such as:

`api_endpoints.dart`

---

## Authentication Tokens

When the backend returns an authentication token, store sensitive tokens using:

`flutter_secure_storage`

Do not store authentication tokens in plain text preferences.

Use an interceptor to automatically attach:

`Authorization: Bearer TOKEN`

to authenticated requests.

---

## Dummy Data

Dummy data is allowed and encouraged while the backend is not ready.

Store temporary development data in a dedicated location such as:

```text
data/
└── dummy/
    └── dummy_data.dart
```

Do not place large dummy lists directly inside screens.

UI code should not know whether data comes from dummy data or the REST API.

The expected flow during early development is:

`Screen → Cubit → Repository → Dummy Data`

Later it becomes:

`Screen → Cubit → Repository → Service → Dio → REST API`

without unnecessarily rewriting the UI.

---

## Responsive Design

All mobile interfaces must be responsive.

The application must work correctly across different phone sizes on:

- Android
- iOS

Do not design screens for only one fixed device size.

Avoid unnecessary hardcoded widths and heights.

Do not rely on values such as:

```dart
width: 390
height: 800
```

for full layouts.

Prefer Flutter layout tools such as:

`MediaQuery`

`LayoutBuilder`

`Expanded`

`Flexible`

`AspectRatio`

`FractionallySizedBox`

`Wrap`

when appropriate.

Layouts must adapt to:

- Small phones
- Standard phones
- Large phones
- iPhone Pro Max-sized devices
- Different aspect ratios

Prevent:

- Render overflow
- Cut-off buttons
- Text overflow
- Unusable cards
- Horizontal scrolling unless intentionally required

Use flexible constraints rather than device-specific layouts.

---

## Arabic Applications

When the application is Arabic:

- Use RTL correctly.
- Align UI elements according to RTL conventions.
- Ensure icons and directional elements make sense in RTL.
- Ensure long Arabic text does not break the layout.
- Keep technical code identifiers in English.

Use:

```dart
textDirection: TextDirection.rtl
```

or application-level RTL configuration when appropriate.

---

## Design System

Do not scatter colors, typography, and repeated styles throughout screens.

Create reusable theme files such as:

```text
core/theme/
├── app_colors.dart
├── app_text_styles.dart
└── app_theme.dart
```

Use centralized constants for:

- Colors
- Typography
- Border radius
- Spacing when appropriate
- Assets
- Strings

Avoid repeating the same style definitions across multiple widgets.

---

## Assets

Store application assets in organized directories.

Example:

```text
assets/
├── images/
│   ├── logo.png
│   ├── products/
│   └── banners/
└── icons/
```

Centralize asset paths in:

`app_assets.dart`

Do not repeatedly hardcode asset paths across screens.

When an official logo or brand reference exists, inspect it and preserve its visual identity.

Do not introduce unrelated primary brand colors unless explicitly requested.

---

## Reusable Widgets

Create shared widgets when the same UI pattern appears repeatedly.

Examples:

`CustomButton`

`CustomTextField`

`LoadingWidget`

`EmptyWidget`

`CustomErrorWidget`

Do not create a shared widget for something used only once unless it clearly improves readability.

Avoid excessive abstraction.

---

## Feature Organization

Keep feature-specific screens, widgets, and Cubits inside their feature directory.

Example:

```text
features/
└── home/
    ├── screens/
    │   └── home_screen.dart
    ├── widgets/
    │   ├── home_header.dart
    │   └── product_card.dart
    └── cubit/
        ├── home_cubit.dart
        └── home_state.dart
```

Do not place feature-specific widgets inside `core/widgets`.

Use `core/widgets` only for genuinely shared widgets.

---

## Models

Use dedicated models for API and application data.

Models should support serialization where needed:

`fromJson`

`toJson`

Keep models focused and avoid unrelated UI logic.

Do not parse large JSON structures directly inside screens or Cubits.

---

## Navigation

Keep navigation centralized where practical.

Prefer a route configuration file such as:

`app/routes.dart`

Do not scatter route names and navigation configuration throughout the project without reason.

For applications with bottom navigation, use one main navigation container rather than recreating the bottom bar independently on every screen.

---

## Code Quality

Follow Dart and Flutter conventions.

Prefer:

- Small focused methods
- Clear naming
- Const constructors when appropriate
- Null safety
- Reusable components
- Clear separation of responsibilities

Avoid:

- Giant screen files
- Giant Cubits
- Duplicate widgets
- Duplicate business logic
- Direct network calls from UI
- Unnecessary packages
- Premature abstraction

Do not over-engineer simple features.

---

## Error Handling

Provide clear handling for:

- Loading
- Empty data
- Network failure
- API errors
- Authentication errors

Do not silently swallow errors.

User-facing errors should be understandable and should not expose internal stack traces or backend implementation details.

---

## Development Workflow

Before making large changes:

1. Inspect the existing project structure.
2. Reuse existing architecture and design conventions.
3. Avoid introducing competing patterns.
4. Make focused changes.
5. Run formatting.
6. Run analysis.
7. Fix relevant errors and warnings.

Use:

`dart format`

and:

`flutter analyze`

after meaningful implementation work.

Run relevant tests when tests exist.

---

## Implementation Discipline

Do not build the entire application in one uncontrolled change unless explicitly requested.

Prefer implementing features incrementally.

Typical order:

1. Foundation
2. Theme
3. Routes
4. Models
5. Dummy data
6. Reusable widgets
7. Feature UI
8. Cubit integration
9. Repository integration
10. API integration
11. Error handling
12. Testing and cleanup

When the backend is not ready, preserve API-ready architecture and use dummy data through repositories.

---

## Final Verification

Before declaring a task complete:

- Ensure the project compiles.
- Run `flutter analyze`.
- Fix introduced errors.
- Verify responsive behavior.
- Verify RTL behavior when applicable.
- Verify no direct API logic exists in screens.
- Verify Cubits depend on repositories.
- Verify repositories/services remain separated.
- Verify repeated design values are centralized where appropriate.

At the end of the task, summarize:

- Files created
- Files modified
- Architectural decisions
- Packages added
- Remaining backend dependencies
- Any known limitations