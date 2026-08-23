# Release Notes - TaskFlow v0.1.0 🚀

Welcome to the initial release of **TaskFlow (v0.1.0)** — a modern, cross-platform project and task management mobile application built with Flutter, Clean Architecture, and BLoC.

---

## ✨ Key Features & Highlights

### 📁 Project & Task Management
- **Multi-Tenant Organization Support**: Seamlessly work within organization boundaries with role-based member assignments.
- **Full CRUD Capabilities**: Create, inspect, edit, and delete projects and tasks with real-time UI synchronization.
- **Advanced Task Filtering**: Filter tasks effortlessly by **Status** (`Todo`, `In Progress`, `Review`, `Done`), **Priority** (`Low`, `Medium`, `High`, `Urgent`), **Assignee**, and **Due Date Ranges**.
- **Task Details & Activity**: Comprehensive task view with editable properties, assignee selector, and chronological comment timelines.

### 🔐 Authentication & Security
- **Role-Based Access Control (RBAC)**: Strict permission boundaries distinguishing Organization Admins from Members.
- **JWT Lifespan & Token Management**: Secure token persistence with automated silent refresh handling.
- **Registration & Validation**: Complete registration flow featuring real-time Confirm Password validation.
- **Secure Debug Logging**: Centralized `AppLogger` active in debug mode only, with automated regex token masking.

### 🎨 Design, Themes & Localization
- **Custom App Identity**: Dedicated 3D neon glassmorphism launcher icon and official display name **TaskFlow**.
- **Theme Modes**: Full support for **Dark Mode**, **Light Mode**, and **System Default** driven by a dedicated theme dropdown selector.
- **Internationalization (i18n)**: Fully localized UI strings powered by `easy_localization` and centralized translation keys.
- **Shimmer / Skeleton Loading**: Replaced generic spinners with animated shimmer skeleton loaders matching exact layout cards.

### 🛠️ Developer & QA Simulation Panel
- Built-in side drawer for rapid testing and resilience verification:
  - **Simulate Offline Mode** with local cache fallback.
  - **Error Injections**: 404 (Not Found), 504 (Timeout), and 400 (Validation Error).
  - **Token Expiry Trigger**: Manually test silent token refresh flows.
  - **Mock Data Reset**: Instantly restore initial demo fixtures.

---

## 📦 What's Included
- **Release APK**: `app-release.apk` (Optimized production build with tree-shaken assets).
- **Test Suite**: Comprehensive unit tests covering authentication logic, token lifespans, JSON serialization, and enum round-trips.
- **Zero Static Analysis Warnings**: Clean `flutter analyze` score.

---

## 👥 Contributors
- [@gauravs1024](https://github.com/gauravs1024)
