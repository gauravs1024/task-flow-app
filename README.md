# TaskFlow — Lightweight Project Management System

TaskFlow is a lightweight project management application built with Flutter. It implements feature-first layering, robust local mock data structures, JWT-style simulated session refitting, offline-first data caching with stale warnings, and a live developer debug simulation drawer.

---

## 1. Project Overview & Architecture

TaskFlow uses a **Feature-First Layered Architecture** matching corporate cleanliness standards:
- **Presentation Layer**: Consists of screens, reusable widgets, and state-management controllers.
- **Business Logic Layer**: Driven by `flutter_bloc` (Cubits) to maintain state isolation.
- **Data Access Layer**: Comprises models (built with `Equatable` for value comparison) and concrete repository implementations communicating with the local mock database.
- **Data Source Layer**: Singleton mock database parser reads `mock-data.json` at startup, simulating latency delays and error injections.

*For full details and a system diagram, please refer to [ARCHITECTURE.md](file:///Users/gaurav/Documents/personal/task_flow_app/ARCHITECTURE.md).*

---

## 2. Technology Stack & Key Libraries

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_bloc` / `cubit`
- **Responsiveness**: `flutter_screenutil` (base size: 375x812)
- **Localization**: `easy_localization` (English assets)
- **Local Cache Persistence**: `shared_preferences`
- **Credential Storage**: `flutter_secure_storage`
- **Value Comparers**: `equatable`

---

## 3. Directory Layout

```
lib/
├── app/                  # Application initialization configuration
│   ├── localization/     # Translation keys configuration
│   └── theme/            # Theme settings (Light & Dark modes)
├── core/                 # Shared data engines
│   └── data/             # In-memory mock database data source
├── features/             # Feature-first modules
│   ├── auth/             # Login, Register, Session check daemon
│   ├── notifications/    # Inbox alert cards feeds
│   ├── projects/         # Dashboards and project management CRUD
│   └── tasks/            # Comments feed, assignee, and task filter lists
```

---

## 4. How to Run, Test, and Build

Ensure your system has the Flutter SDK installed.

### Get Dependencies
```bash
flutter pub get
```

### Run Locally
```bash
flutter run
```

### Run Automated Tests
```bash
flutter test
```

### Build Production APK
```bash
flutter build apk --release
```

---

## 5. Test Credentials (auth_mock.json)

Use these credentials to test role-based constraints (e.g., project modifications are restricted to admins):

| Organization | Email | Password | Role |
|---|---|---|---|
| **Nimbus Digital** | `ava.admin@nimbusdigital.test` | `Password123!` | `org_admin` |
| **Nimbus Digital** | `marcus.member@nimbusdigital.test` | `Password123!` | `member` |
| **Harborlight Studios** | `daniel.admin@harborlightstudios.test` | `Password123!` | `org_admin` |
| **Harborlight Studios** | `elena.member@harborlightstudios.test` | `Password123!` | `member` |

---

## 6. How to Trigger Simulated Errors & Offline States

Open the **Navigation Drawer** (hamburger menu) on the main dashboard to access the **Developer Testing Panel**:

1. **Simulate Offline Mode** (Task 08):
   - Toggle **Simulate Offline Mode** on.
   - Refresh the page (pull-to-refresh). The app serves cached data and displays a **"Stale Data (Offline Mode)"** warning banner at the top of the list.
2. **Error Injections** (Task 07):
   - Toggle **Simulate 404 (Not Found)**, **Simulate Timeout (504)**, or **Simulate Validation Error** on.
   - Trigger any action (e.g., refresh or edit). The application displays appropriate error notifications and fallback screens.
3. **Session Expiry Trigger** (Task 02):
   - Tap **Simulate Token Expiry**.
   - An expired state is flagged. The background refresh daemon intercepts this status on its next tick (`10s` intervals) and silent-refreshes the session keys.
4. **Reset Database**:
   - Tap **Reset Mock Data** to wipe out active session cache edits and reset JSON collections to their original values.
