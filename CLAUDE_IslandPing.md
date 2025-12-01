SYSTEM INSTRUCTION:
You are a high-level AI architect designing a minimal, premium telecom alert system that is both seamless and capable of identifying the general location of users affected by outages. The app must remain lightweight, not require deep hardware integration, and ensure privacy while providing location-based alerts.

APP OVERVIEW:
- **Purpose:** A multi-telecom alert system that notifies users and telecom admins of service outages and can identify the approximate area of the affected users.
- **User Scenario:** When a cable break or outage occurs, the system detects the disruption and notifies all users in the affected area, as well as the telecom administrators.

CORE REQUIREMENTS:
1. **Seamless Outage Detection:**  
   - Use lightweight external checks (e.g., periodic pings) to determine if a user’s connection is down.  
   - No need for deep integration with modems or routers.

2. **Location Awareness:**  
   - When an outage is detected, approximate the user’s general area based on network data or cell tower location.  
   - Use this location data to identify the affected region without pinpointing exact addresses, ensuring privacy.

3. **Automatic Area-Based Notifications:**  
   - Send push notifications to all users within the identified outage zone.  
   - Notify the telecom’s admin dashboard with a map or description of the impacted area.

4. **Lightweight and Professional:**  
   - Ensure the app is minimalistic in design and function, with a focus on ease of use.  
   - Follow modern 2026 UI/UX standards to create a polished, premium user experience.

5. **Privacy and Simplicity:**  
   - Maintain user privacy by only using approximate location data and not exact home addresses.  
   - Keep the codebase and integration as straightforward as possible, allowing any telecom to adopt it easily.

OUTPUT EXPECTATIONS:
- Produce a detailed app design and functional specification that includes:
  - Automatic outage detection and location-based alert dispatching.
  - A mechanism for determining the affected area and notifying users and admins.
  - A clean, professional interface that is easy to navigate.

---

## TECH STACK (Cross-Platform)

**Framework:** Flutter (Dart)
**Platforms:** Android, iOS, Windows, macOS, Linux
**State Management:** Riverpod
**Backend:** Firebase (FCM, Firestore, Auth)
**Maps:** Google Maps SDK for Flutter
**Local Storage:** Hive
**Networking:** Dio + connectivity_plus
**IDE:** Android Studio with Flutter plugin

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.9 | State management |
| firebase_core | ^2.24.2 | Firebase initialization |
| firebase_messaging | ^14.7.10 | Push notifications |
| cloud_firestore | ^4.14.0 | Real-time database |
| google_maps_flutter | ^2.5.3 | Map display |
| geolocator | ^10.1.0 | Device location |
| geocoding | ^2.1.1 | Reverse geocoding |
| connectivity_plus | ^5.0.2 | Network status |
| hive | ^2.2.3 | Local storage |
| dio | ^5.4.0 | HTTP client |

---

## SECURITY CONSIDERATIONS

### Data Privacy
- All communications between the app and backend are encrypted using TLS/HTTPS
- No sensitive personal data (passwords, exact addresses) is stored locally or transmitted
- Location data is approximate only (area/neighborhood level, not exact coordinates)
- User data is anonymized before aggregation for outage detection

### Minimal Permissions
- **Internet Access:** Required for connectivity checks and notifications
- **Coarse Location:** Only approximate area needed for outage mapping
- **Notifications:** For receiving outage alerts
- No access to contacts, camera, microphone, or storage

### Secure Notifications
- Uses Firebase Cloud Messaging (FCM), a Google-trusted service
- All notification payloads are encrypted in transit
- No sensitive data included in notification content
- Server-side validation before sending alerts

### No Direct Modem/Router Access
- App uses external ping checks, not direct hardware integration
- No local network scanning or device enumeration
- Reduces attack surface by avoiding privileged network access
- Works entirely through standard Android/Flutter network APIs

---

## CLAUDE MEMORY SYSTEM

This project includes a memory system in `.claude/` folder for session continuity:

| File | Purpose |
|------|---------|
| `SESSION_STATE.md` | Current task, where to resume |
| `PROJECT_CONTEXT.md` | Architecture decisions, tech stack |
| `TASK_LOG.md` | Completed tasks with timestamps |
| `BLOCKERS.md` | Issues and unresolved questions |

**How to use:** At start of each session, Claude reads SESSION_STATE.md to know where to continue. At end of session, update the file with current progress.

---

## PROJECT FILES

| File | Description |
|------|-------------|
| `CLAUDE_IslandPing.md` | This file - project specification |
| `PROJECT_REPORT.md` | Beginner-friendly status report |
| `.claude/*` | Claude memory system files |
| `lib/` | Flutter application source code |
| `pubspec.yaml` | Flutter dependencies |
