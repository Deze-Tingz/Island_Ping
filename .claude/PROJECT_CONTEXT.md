# Island_Ping - Project Context

## Project Overview
**Purpose:** Multi-telecom alert system for service outage notifications
**Target:** Android/iOS users and telecom administrators (desktop dashboard)
**Core Function:** Detect outages, identify affected areas, notify users

---

## Tech Stack
| Category | Choice | Version |
|----------|--------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | Riverpod | 2.4.9+ |
| Backend | Firebase | Latest |
| Maps | Google Maps Flutter | 2.5.3 |
| Local Storage | Hive | 2.2.3 |
| Networking | Dio | 5.4.0 |
| Connectivity | connectivity_plus | 5.0.2 |

---

## Architecture Decisions

### Decision 1: Flutter over Native Android
- **Date:** 2025-12-01
- **Decision:** Use Flutter instead of native Kotlin/Android
- **Rationale:** Single codebase for Android, iOS, and Desktop (Windows)
- **Trade-off:** Slightly less native performance, but faster development
- **Status:** Implemented

### Decision 2: Riverpod for State Management
- **Date:** 2025-12-01
- **Decision:** Use Riverpod instead of Provider or BLoC
- **Rationale:** Type-safe, compile-time checked, better testability
- **Alternatives Considered:** Provider (too basic), BLoC (too verbose)
- **Status:** Pending implementation

### Decision 3: Firebase for Backend
- **Date:** 2025-12-01
- **Decision:** Use Firebase (FCM, Firestore, Auth)
- **Rationale:** Free tier, reliable, excellent Flutter integration
- **Status:** Pending implementation

### Decision 4: Hive for Local Storage
- **Date:** 2025-12-01
- **Decision:** Use Hive instead of SQLite/SharedPreferences
- **Rationale:** Fast, pure Dart, no native dependencies, type-safe
- **Status:** Pending implementation

### Decision 5: Approximate Location Only
- **Date:** 2025-12-01
- **Decision:** Only use coarse location (neighborhood level)
- **Rationale:** Privacy protection - no need for exact addresses
- **Status:** Pending implementation

---

## Key Components

### Core Services
1. **ConnectivityService** - Monitors network status, detects outages
2. **LocationService** - Gets approximate user location (area/neighborhood)
3. **FirebaseService** - Handles FCM push notifications

### Providers (Riverpod)
1. **connectivityProvider** - Stream of connection status
2. **locationProvider** - User's current area
3. **alertsProvider** - List of active outage alerts

### UI Screens
1. **HomeScreen** - Main dashboard with status
2. **AlertsScreen** - List of current outages
3. **OutageMapScreen** - Map showing affected areas
4. **SettingsScreen** - User preferences

---

## API Contracts (Planned)
```
POST /api/report-outage     - Report detected outage
GET  /api/outages/{area}    - Get outages in an area
WS   /ws/alerts             - Real-time alert stream
```

---

## Security Principles
- All communications encrypted (TLS/HTTPS)
- No exact location stored (approximate only)
- Minimal permissions requested
- Firebase Cloud Messaging for secure notifications
- No direct modem/router access

---

## Important Notes
- Privacy first: Never store exact user locations
- Battery optimization: Use passive location where possible
- Offline support: Queue alerts when offline, sync when back online
- Desktop version: Same codebase, separate UI considerations

---
*Update this file when major architectural decisions are made*
