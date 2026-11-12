# Chiniot Power HSE Management System - Backend & Data Architecture

## Overview
The Chiniot Power HSE backend is structured as a resilient RESTful / gRPC micro-architecture designed to interface seamlessly with the Flutter cross-platform client (Android, iOS, Windows, and macOS).

### Key Architectural Components
1. **Database**: PostgreSQL 15+ with `PostGIS` extension for native geospatial queries and plant zone geofencing.
2. **Object Storage**: MinIO / AWS S3 for secure, encrypted incident and resolution photo retention.
3. **Queue & Caching**: Redis for asynchronous emergency dispatch triggers and FCM notification workers.
4. **API Gateway & Microservices**: Built via Node.js NestJS or Python FastAPI with JWT RBAC middleware.

---

## 1. Quick Start with Docker
```bash
cd backend
docker-compose up -d
```
This will launch:
- PostgreSQL + PostGIS on `localhost:5432` (Auto-runs `database/schema.sql`).
- MinIO S3 API on `localhost:9000` (Console on `localhost:9001`).
- Redis on `localhost:6379`.

---

## 2. Default Seed Employee Accounts
All seed accounts authenticate with default password: `Chiniot@2026`

| Employee ID | Name | Role | Plant Area |
| :--- | :--- | :--- | :--- |
| `CP-EMP-1001` | Engr. Tariq Khan | Super Admin | Plant Headquarters |
| `CP-EMP-1002` | Asim Raza | Plant HSE Manager | Main Control Station |
| `CP-EMP-1003` | Hamza Ali | HSE Inspector / Officer | Turbine & Switchyard |
| `CP-EMP-1004` | Rashid Mehmood | Field Technician | Boiler Unit 1 |

---

## 3. Core REST API Endpoints

### Auth & RBAC
- `POST /api/v1/auth/login`: Validate Employee ID (`CP-EMP-XXXX`) & Password. Returns Access & Refresh JWTs.
- `POST /api/v1/auth/register`: Provision new employee profile against master registry.
- `POST /api/v1/auth/refresh`: Issue new access token.

### Hazards & Incidents
- `GET /api/v1/hazards`: List hazards with optional query filters `plant_zone` and `status`.
- `POST /api/v1/hazards`: Create hazard report with GPS coordinate tagging & 5x5 risk evaluation.
- `PATCH /api/v1/hazards/:id/capa`: Advance CAPA status. Requires resolution photo & supervisor digital signature for closure.
- `POST /api/v1/hazards/batch-sync`: Reconciles offline submissions buffered in mobile SQLite/Hive storage.

### Daily Checklists
- `GET /api/v1/checklists/templates`: Retrieve configured unit templates (Boiler, Turbine, Switchyard, Chemical Storage).
- `GET /api/v1/checklists`: Retrieve historical shift audits.
- `POST /api/v1/checklists`: Submit completed audit with Pass/Fail/NA values & mandatory failure deviation notes.

### High-Priority Emergency Alarms
- `POST /api/v1/alarms/trigger`: Broadcast high-priority alarm via FCM Push, transactional emails, and desktop sirens.
- `POST /api/v1/alarms/:id/acknowledge`: Record digital acknowledgment by plant operator.

### Training & Competency
- `GET /api/v1/trainings`: List safety training modules (LOTO, Confined Space, Fire Drill).
- `GET /api/v1/trainings/my-certificates`: Retrieve active certificates with 30, 15, and 7-day expiration alerts.
- `POST /api/v1/trainings/:id/attendance`: Verify QR-based attendance at training hall or muster point.

