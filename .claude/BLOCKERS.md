# Island_Ping - Blockers & Issues

## Active Blockers

*No active blockers at this time*

---

## Unresolved Questions

### Question 1: Firebase Project Setup
- **Asked:** 2025-12-01
- **Question:** Does the user have a Firebase project created already?
- **Context:** Need Firebase project for FCM and Firestore
- **Options:**
  - Option A: Create new Firebase project
  - Option B: Use existing Firebase project
- **Decision Needed By:** Before implementing Firebase services
- **Status:** Pending user input

### Question 2: Google Maps API Key
- **Asked:** 2025-12-01
- **Question:** Does the user have a Google Maps API key?
- **Context:** Required for map functionality in the app
- **Options:**
  - Option A: User provides existing API key
  - Option B: Need to create new API key in Google Cloud Console
- **Decision Needed By:** Before implementing map features
- **Status:** Pending user input

---

## Technical Notes

### Note 1: Windows Desktop Support
- Flutter desktop support for Windows needs to be enabled
- Command: `flutter config --enable-windows-desktop`
- May need Visual Studio with C++ desktop development workload

### Note 2: Android SDK Requirements
- Min SDK: 21 (Android 5.0) for Firebase
- Target SDK: 34 (Android 14)
- Compile SDK: 34

---

## Resolved (Archive)

*No resolved blockers yet*

---
*Update this file when encountering or resolving blockers*
