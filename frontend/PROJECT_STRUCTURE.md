# Aetram-ERB: Project Architecture & Structure Guide

This document outlines the directory structure, architectural layers, and development conventions for the **Aetram-ERB** Flutter application.

---

## 1. Directory Tree Overview

```text
aetram_erb/
│
├── android/                             # Native Android project configuration
├── ios/                                 # Native iOS project configuration
├── web/                                 # Web platform entry points & configuration
│
├── assets/                              # Static app assets
│   ├── images/                          # Image assets
│   │   ├── logo.png                     # Standard company logo
│   │   ├── app_logo.png                 # Main application branding icon
│   │   └── placeholder_profile.png      # Avatar fallback placeholder
│   ├── icons/                           # Vector icons (SVG)
│   │   ├── home.svg                     # Home navigation icon
│   │   ├── attendance.svg               # Attendance & calendar icon
│   │   └── profile.svg                  # User profile icon
│   ├── fonts/                           # Custom typography (Inter, Roboto, Poppins)
│   └── animations/                      # Lottie animations (.json)
│
├── lib/
│   ├── main.dart                        # App bootstrap, Riverpod setup & global initialization
│   ├── app.dart                         # MaterialApp configuration, routing, theme & localization
│   │
│   ├── core/                            # App-wide, domain-agnostic foundations
│   │   ├── config/                      # Environment and flavor configurations
│   │   │   ├── app_config.dart          # Base URLs, timeouts, app metadata
│   │   │   └── environment.dart         # Dev, Staging, Production flavor switchers
│   │   │
│   │   ├── constants/                   # Global constant definitions
│   │   │   ├── app_constants.dart       # App-wide fixed values & keys
│   │   │   ├── api_constants.dart       # API endpoints & route paths
│   │   │   └── asset_constants.dart     # Static path references to assets
│   │   │
│   │   ├── network/                     # Network communication layer
│   │   │   ├── api_client.dart          # HTTP client wrapper (GET, POST, PUT, DELETE)
│   │   │   ├── api_interceptor.dart     # Auth headers, logging & retry interceptors
│   │   │   ├── api_exceptions.dart      # Normalized network & server exceptions
│   │   │   └── network_info.dart        # Device connectivity checker
│   │   │
│   │   ├── auth/                        # Central authentication & session utilities
│   │   │   ├── auth_service.dart        # Authentication coordinator interface
│   │   │   ├── token_manager.dart       # Secure token storage & retrieval
│   │   │   └── session_manager.dart     # Session state & expiration watchdog
│   │   │
│   │   ├── storage/                     # Data persistence abstractions
│   │   │   ├── secure_storage.dart      # Encrypted storage for sensitive tokens
│   │   │   └── local_storage.dart       # Key-value persistence (SharedPreferences)
│   │   │
│   │   ├── routing/                     # Navigation infrastructure
│   │   │   ├── app_router.dart          # Route generator & route transitions
│   │   │   └── route_names.dart         # Static route name constants
│   │   │
│   │   ├── theme/                       # Visual design system & styling tokens
│   │   │   ├── app_theme.dart           # Light & Dark ThemeData builders
│   │   │   ├── app_colors.dart          # Color palettes, accents & status tones
│   │   │   ├── app_text_styles.dart     # Typography styles & font weights
│   │   │   └── app_dimensions.dart      # Spacing, padding, and corner radius tokens
│   │   │
│   │   ├── utils/                       # Generic utility functions
│   │   │   ├── date_utils.dart          # Date/time formatting and comparison helpers
│   │   │   ├── validators.dart          # Input validation (email, password, text)
│   │   │   └── formatters.dart          # Currency, numbers, and text formatters
│   │   │
│   │   └── widgets/                     # Reusable foundational design system UI components
│   │       ├── buttons/                 # Primary, secondary, outline, and text buttons
│   │       ├── cards/                   # Standard elevated, flat, and outlined cards
│   │       ├── dialogs/                 # Alert dialogs, confirmation dialogs, bottom sheets
│   │       ├── dropdowns/               # Custom styled dropdown select fields
│   │       ├── loaders/                 # Progress indicators, skeletons, and shimmer views
│   │       └── inputs/                  # Text fields, search fields, date pickers
│   │
│   ├── features/                        # Feature-First Clean Architecture modules
│   │   │
│   │   ├── authentication/              # Login, MFA, Password Reset
│   │   │   ├── data/                    # Models, datasources, and repository implementations
│   │   │   ├── domain/                  # Entities, repository interfaces, and use cases
│   │   │   └── presentation/            # Riverpod providers, screens, and localized widgets
│   │   │
│   │   ├── home/                        # Landing home dashboard
│   │   │   └── presentation/            # Screens, widgets, and view providers
│   │   │
│   │   ├── app_switcher/                # Multi-app module launcher (HRMS, PMS, Ticketing)
│   │   │   └── presentation/            # Grid switcher screen & providers
│   │   │
│   │   ├── hrms/                        # Human Resource Management System
│   │   │   ├── dashboard/               # HRMS dashboard KPI summary
│   │   │   ├── employees/               # Staff directory & team lists
│   │   │   ├── attendance/              # Attendance logs & Work From Home (WFH) approvals
│   │   │   ├── leave/                   # Leave balance, requests & leave approvals
│   │   │   ├── payroll/                 # Salary slips, tax declarations, bonus statements
│   │   │   ├── assets/                  # Company hardware & asset allocations
│   │   │   ├── approvals/               # Consolidated Approvals Hub (Leave & WFH queues)
│   │   │   └── profile/                 # Employee personal & professional profile
│   │   │
│   │   ├── pms/                         # Performance Management System
│   │   │   ├── dashboard/               # Performance overview & scorecards
│   │   │   ├── goals/                   # Quarterly OKRs & Key Results
│   │   │   ├── appraisal/               # Self-review, manager appraisal & feedback
│   │   │   └── reports/                 # Departmental performance analytics
│   │   │
│   │   └── ticketing/                   # Internal IT & HR Support Ticketing
│   │       ├── dashboard/               # Open/resolved ticket counts
│   │       ├── tickets/                 # Ticket creation & chat thread view
│   │       ├── categories/              # Hardware, software, payroll, and admin categories
│   │       └── history/                 # Past closed tickets and resolution audit logs
│   │
│   └── shared/                          # Cross-feature reusable domain models & utilities
│       ├── widgets/                     # Generic domain-aware widgets (e.g., EmptyView, ErrorView)
│       ├── models/                      # Common DTOs and API envelopes (e.g., ApiResponse<T>)
│       ├── enums/                       # Shared status and role enums (e.g., ApprovalStatus)
│       └── extensions/                  # Context, String, and DateTime Dart extensions
│
├── test/                                # Automated Unit & Widget Tests
│   ├── core/                            # Core service and utility tests
│   ├── features/                        # Use case, repository, and provider tests
│   └── widgets/                         # Individual component rendering tests
│
├── integration_test/                    # End-to-end integration tests
│   └── app_test.dart                    # App startup & primary user journeys
│
├── pubspec.yaml                         # Flutter dependencies & asset declarations
├── analysis_options.yaml                # Linting and static analysis rules
├── .gitignore                           # Git ignore rules
└── README.md                            # Quickstart and project summary
```

---

## 2. Architectural Layers & Separation of Concerns

The codebase follows **Clean Architecture** principles combined with **Feature-First modularization**:

### 2.1 The Three Core Layers

```text
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   Screens, Widgets, Riverpod StateNotifiers/Providers   │
└───────────────────────────┬────────────────────────────┘
                            │ depends on
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│     Entities, Repository Interfaces, Use Cases         │
└───────────────────────────▲────────────────────────────┘
                            │ implemented by
┌───────────────────────────┴────────────────────────────┐
│                       Data Layer                       │
│    DTO Models, Remote/Local Data Sources, Repositories │
└────────────────────────────────────────────────────────┘
```

1. **Domain Layer (Pure Dart)**:
   - Contains business logic that is independent of any UI framework, third-party libraries, or database drivers.
   - **Entities**: Core business objects (e.g. `UserEntity`, `HrmsLeaveRequest`).
   - **Repository Interfaces**: Abstract contracts defining required operations.
   - **Use Cases**: Specific business operations (e.g. `LoginUseCase`, `ApproveLeaveUseCase`).

2. **Data Layer**:
   - Manages data retrieval and storage from external APIs, databases, or device hardware.
   - **Data Transfer Objects (DTOs)**: JSON-serializable models mapping external schemas to domain entities.
   - **Data Sources**: Concrete network callers (`AuthRemoteDataSource`) or database clients.
   - **Repository Implementations**: Implement domain repository interfaces and handle caching/data transformation.

3. **Presentation Layer**:
   - Manages UI presentation and reactive user state.
   - **Screens**: Top-level page views (e.g., `HrmsApprovalDashboardPage`, `LoginPage`).
   - **Widgets**: Reusable, atomic UI elements specific to that feature.
   - **Providers**: State management powered by **Riverpod** (`NotifierProvider`, `FutureProvider`).

---

## 3. Core Modules Guide

| Module | Location | Purpose |
| :--- | :--- | :--- |
| **Config** | `lib/core/config/` | Manages environment-specific properties (Dev, Staging, Prod) and app constants. |
| **Constants** | `lib/core/constants/` | Centralizes API route strings, static assets, and app keys. |
| **Network** | `lib/core/network/` | Houses the `ApiClient`, interceptors for authentication tokens, and exception handlers. |
| **Auth** | `lib/core/auth/` | Manages token lifecycle, session checks, and login state. |
| **Storage** | `lib/core/storage/` | Provides unified interfaces for secure keystore and key-value persistence. |
| **Routing** | `lib/core/routing/` | Defines route names and on-generate route transitions. |
| **Theme** | `lib/core/theme/` | Houses styling tokens: colors, spacing, typography, and dark/light ThemeData. |
| **Utils** | `lib/core/utils/` | Date parsing, text formatters, and form validation helpers. |
| **Widgets** | `lib/core/widgets/` | Foundational UI library components (buttons, text fields, cards, loaders). |

---

## 4. Coding & Development Standards

1. **Imports**: Prefer package imports (e.g., `import 'package:aetram_erb/core/...';`) over deep relative imports (`../../../../`).
2. **Immutability**: Domain entities and state classes should be `@immutable` with `final` fields.
3. **Stateless UI**: Favor `ConsumerWidget` and `StatelessWidget`. Use `ConsumerStatefulWidget` only when managing local transient animations, scroll controllers, or text controllers.
4. **Error Handling**: Network operations must throw typed `ApiException` subclasses and return user-friendly messages via presentation layer state.
5. **Static Analysis**: All code must pass `flutter analyze` with **0 warnings and 0 errors**.
