# Chiniot Power HSE Management System

An enterprise cross-platform Health, Safety, and Environment (HSE) management suite built with Flutter 3.x for **Android, iOS, Windows, and macOS Desktop** from a single codebase.

---

## 🏗️ Architecture Overview

The codebase is engineered strictly following **Clean Architecture** and event-driven state management with **Flutter BLoC / Cubit**:

```
lib/
├── core/
│   ├── constants/        # Plant zones, HSE color coding, API endpoints
│   ├── errors/           # Failures and Exceptions mapping
│   ├── network/          # Dio HTTP client, JWT interceptor, auto token-refresh
│   ├── platform/         # Clean desktop vs mobile isolation (GPS, Camera, Audio Buzzer)
│   ├── storage/          # FlutterSecureStorage, Hive boxes, OfflineSyncQueue
│   ├── theme/            # Industrial dark command center theme & field daylight theme
│   └── utils/            # 5x5 Risk Calculator, CSV exporter, PDF report generator
├── features/
│   ├── auth/             # Employee ID (CP-EMP-XXXX) verification, JWT tokens, RBAC
│   ├── hazards/          # Risk reporting, GPS coordinates, 5x5 Matrix, CAPA workflow
│   ├── checklists/       # Dynamic shift checklist engine, Pass/Fail/NA toggles, PDF turnover
│   ├── emergency_alarms/ # Safeguarded alarm dispatch, desktop audio buzzer modal, multi-channel
│   ├── training/         # Safety course catalog, automated 30/15/7 day alerts, QR attendance
│   ├── dashboard/        # Executive Manager Dashboard, KPI metrics, CSV/PDF export
│   └── navigation/       # Adaptive NavigationRail (Desktop) & NavigationBar (Mobile)
└── main.dart             # Dependency injection, Hive initialization, MultiBlocProvider
```

---

## 🚀 Key Functional Modules

### 1. Auth & Employee ID Verification
- **Regex Enforcement**: Employee IDs must strictly conform to `^CP-EMP-\d{4}$` (e.g. `CP-EMP-1001`, `CP-EMP-1002`).
- **Role-Based Access Control (RBAC)**:
  - `Worker`: Field hazard reporting, daily checklists, view assigned safety trainings.
  - `Inspector`: Hazard verification, 5x5 rating, daily walkdown audits.
  - `HSE Manager`: CAPA approvals, template authoring, emergency dispatch, dashboard analytics.
  - `Super Admin`: Plant hierarchy, audit trail exports, credential provisioning.
- **Biometric Sign-in**: Supported on mobile devices with `flutter_secure_storage` credential caching.

### 2. Risk Identification & Incident Reporting
- **Native Camera & File Picker**: Uses `image_picker` on mobile with graceful file dialog fallback on desktop.
- **Geolocation Service**: Uses `geolocator` on mobile; falls back to plant zone reference coordinates on desktop workstations.
- **Offline Buffering**: Submissions without connectivity are queued in local Hive storage (`OfflineSyncQueue`) and automatically reconciled when reconnected.

### 3. 5x5 Risk Matrix & CAPA Management
- **Quantitative Formula**: `Score = Probability (1-5) * Severity (1-5)` resulting in scores from 1 to 25:
  - Low Risk (1–4, Green)
  - Medium Risk (5–9, Yellow)
  - High Risk (10–14, Orange)
  - Critical / Extreme Risk (15–25, Red - Stop Work)
- **Lifecycle Workflow**: `Draft` → `Reported` → `Under Review` → `Assigned` → `Action Taken` → `Verification` → `Closed`.
- **Supervisory Digital Approval**: Closing a CAPA requires mandatory resolution photo proof and cryptographic supervisor sign-off.

### 4. Daily Safety Checklist Engine
- Dynamic templates for:
  - Boiler Unit 1 Shift Safety Inspection
  - Steam Turbine Generator Operational Safety Audit
  - 132kV Switchyard Substation Daily Walkdown
  - Chemical & Acid Storage Hazardous Material Audit
- **Pass / Fail / NA Toggles**: Marking an item as "Fail" opens a mandatory deviation modal requiring notes and evidence photo.
- **Shift Turnover Reports**: Generates formal PDF compliance reports with digital sign-off blocks.

### 5. High-Priority Alarm & Emergency Dispatch
- **Accidental Dispatch Safeguard**: Confirmation safeguard checkboxes and structured reason fields prevent accidental trips.
- **Multi-Channel Dispatch**: Triggers FCM Push, SendGrid/SMTP emails, and desktop siren alerts.
- **Desktop Floating Alert Modal**: Pulsing audio-visual modal with continuous audible buzzer (`audioplayers`) that can be silenced upon operator acknowledgment.

### 6. Employee Safety Training Tracker
- Mandatory courses: LOTO, Confined Space Entry, Chemical Safety, High Voltage Clearance, Fire Drills.
- **Certification Validity Tracking**: Automated expiry flags at 30, 15, and 7 days.
- **QR Attendance**: Displays employee attendance tokens for rapid badge scanning at muster points.

### 7. Desktop Manager Dashboard
- Adaptive shell using `NavigationRail` on Windows/macOS and `NavigationBar` on mobile.
- Plant KPI metrics cards, plant zone hazard density progress bars, live hazard data tables, CSV and PDF report export.

---

## 🗄️ Backend & Database Architecture
Located in `backend/`:
- `database/schema.sql`: PostgreSQL 15+ schema with `PostGIS` extension for spatial coordinates (`GEOMETRY(Point, 4326)`).
- `docker-compose.yml`: Spawns PostgreSQL + PostGIS, MinIO S3 object storage for incident photos, and Redis.

To start the backend infrastructure:
```bash
cd backend
docker-compose up -d
```

