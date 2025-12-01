# Island_Ping Project Report

> A simple, always-updated guide to understand and continue this project

---

## What Is This Project?

**Island_Ping** is an app that alerts people when their internet or telecom service goes down.

**Think of it like this:** When your internet cable gets cut, the app tells you (and your neighbors in the same area) what's happening, and also tells the internet company where the problem is.

### The Three Main Things It Does:
1. **Detects outages** - Knows when your connection stops working
2. **Finds the affected area** - Figures out the general neighborhood affected
3. **Sends notifications** - Alerts everyone in that area + the telecom company

---

## Project Status Dashboard

| Area | Status | Progress |
|------|--------|----------|
| Project Setup | Done | 100% |
| Core Structure | Done | 100% |
| Outage Detection | In Progress | 80% |
| Location Services | In Progress | 70% |
| Push Notifications | Pending | 10% |
| User Interface | In Progress | 40% |
| Testing | Pending | 0% |

**Last Updated:** 2025-12-01

---

## How The App Is Built (Architecture)

### The Pattern We Use - Explained Simply

We use something called **Clean Architecture with Riverpod**. Here's what that means:

```
USER SEES          LOGIC HAPPENS       DATA LIVES
    |                    |                  |
    v                    v                  v
SCREENS     <--->    PROVIDERS    <--->   SERVICES
(UI)              (State Manager)      (Data Source)
```

**Screens (What you see):**
- The buttons, text, and images on screen
- Lives in: `lib/presentation/screens/`

**Providers (The brain):**
- Manages app state using Riverpod
- Decides what to show and when
- Lives in: `lib/providers/`

**Services (The data):**
- Where information is fetched and stored
- Talks to the internet, Firebase, and sensors
- Lives in: `lib/data/services/`

### Why This Matters For You

When you want to change something:
- **Change how it looks?** Edit files in `lib/presentation/`
- **Change app state/logic?** Edit files in `lib/providers/`
- **Change where data comes from?** Edit files in `lib/data/`

---

## Key Files You'll Work With

### The Most Important Files

| File | What It Does | When To Edit |
|------|--------------|--------------|
| `lib/main.dart` | App entry point | Initialization changes |
| `lib/app.dart` | App configuration | Theme, navigation |
| `lib/presentation/screens/home/home_screen.dart` | Main dashboard | UI changes |
| `lib/providers/connectivity_provider.dart` | Connection state | Detection logic |
| `lib/providers/alert_provider.dart` | Alert management | Notification logic |
| `lib/data/services/connectivity_service.dart` | Ping checks | Outage detection |
| `lib/data/services/location_service.dart` | Location tracking | Area identification |

### Configuration Files

| File | What It Does |
|------|--------------|
| `pubspec.yaml` | Lists all libraries we use |
| `android/app/src/main/AndroidManifest.xml` | Android permissions |
| `.claude/SESSION_STATE.md` | Where Claude left off |

---

## What's Done (Completed Tasks)

### Setup Phase
- [x] Git repository initialized
- [x] Flutter project created
- [x] Dependencies added to pubspec.yaml
- [x] Folder structure created
- [x] Claude memory system set up

### Core Features
- [x] Main app entry point (main.dart)
- [x] App theme (light/dark mode)
- [x] Home screen UI
- [x] Data models (Outage, Alert, UserLocation)
- [x] Connectivity service
- [x] Location service
- [x] Riverpod providers

### In Progress
- [ ] Firebase integration
- [ ] Map screen with outage areas
- [ ] Settings screen
- [ ] Alerts list screen

### Not Started
- [ ] Push notifications
- [ ] Backend API integration
- [ ] Unit tests
- [ ] Desktop UI optimizations

---

## What's Next (Upcoming Tasks)

1. **[HIGH]** Configure Firebase project and add google-services.json
2. **[HIGH]** Implement push notification handling
3. **[MEDIUM]** Create alerts list screen
4. **[MEDIUM]** Create map screen with Google Maps
5. **[MEDIUM]** Create settings screen
6. **[LOW]** Add unit tests
7. **[LOW]** Optimize desktop UI

---

## How To Pick Up Where You Left Off

### For Claude (AI Assistant)

1. **Read these files first:**
   - `.claude/SESSION_STATE.md` - What was being worked on
   - `.claude/BLOCKERS.md` - Any problems to solve

2. **Check the status:**
   - Look at "What's Done" above
   - Find the first unchecked item in "In Progress"

3. **Start working:**
   - Follow the sequence in "What's Next"
   - Update this report as you go

### For Human Developers

1. **New to the project?**
   - Read this entire file first
   - Run `flutter pub get` to install dependencies
   - Run `flutter run` to see the app

2. **Returning to the project?**
   - Check "What's Next" section
   - Look at recent git commits: `git log --oneline -10`
   - Check `.claude/SESSION_STATE.md` for context

---

## Common Tasks (How To...)

### How to run the app
```bash
flutter pub get        # Install dependencies
flutter run            # Run on connected device
flutter run -d windows # Run on Windows desktop
```

### How to add a new screen
1. Create folder: `lib/presentation/screens/newscreen/`
2. Create `new_screen.dart` with a ConsumerWidget
3. Add navigation from home or use GoRouter

### How to add a new provider
1. Create file in `lib/providers/`
2. Define provider using Riverpod syntax
3. Use `ref.watch()` or `ref.read()` in widgets

### How to add a new service
1. Create file in `lib/data/services/`
2. Create a class with the service logic
3. Create a provider in `lib/providers/`
4. Inject and use in widgets

---

## Quick Reference

### Project Info
- **Package Name:** `com.islandping.island_ping`
- **Min Android Version:** 5.0 (API 21)
- **Target Android Version:** 14 (API 34)
- **Language:** Dart/Flutter

### Key Dependencies
| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| firebase_core | Firebase initialization |
| firebase_messaging | Push notifications |
| google_maps_flutter | Map display |
| geolocator | Device location |
| connectivity_plus | Network status |
| hive | Local storage |
| dio | HTTP requests |

### Useful Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for release
flutter build apk
flutter build windows

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean and rebuild
flutter clean && flutter pub get
```

---

## Folder Structure

```
Island_Ping/
├── .claude/                    # Claude memory system
├── .git/                       # Git repository
├── android/                    # Android-specific files
├── ios/                        # iOS-specific files
├── windows/                    # Windows desktop files
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # App configuration
│   ├── core/                  # Constants, theme, utils
│   ├── data/                  # Models, services, repos
│   ├── providers/             # Riverpod providers
│   └── presentation/          # UI screens & widgets
├── test/                       # Unit tests
├── pubspec.yaml               # Dependencies
├── CLAUDE_IslandPing.md       # Original spec
└── PROJECT_REPORT.md          # This file
```

---

## Notes & Decisions Log

### Why Flutter instead of Native?
Flutter allows us to write one codebase for Android, iOS, and Windows. Faster development and easier maintenance.

### Why Riverpod for state management?
It's type-safe, compile-time checked, and easier to test than Provider. Google recommends it for new Flutter projects.

### Why approximate location only?
Privacy protection! We only need to know the general area (neighborhood) not exact addresses. This protects user privacy while still enabling area-based alerts.

### Why Firebase for backend?
Free tier is generous, excellent Flutter integration, real-time capabilities, and push notifications built-in.

---

## Troubleshooting

### "Flutter not found"
Make sure Flutter is in your PATH. Run `flutter doctor` to diagnose.

### Build fails with dependency errors
Run `flutter clean` then `flutter pub get`.

### App crashes on startup
Check that all permissions are declared in AndroidManifest.xml.

### Location not working
1. Check location permission is granted
2. Enable location services on device
3. Check AndroidManifest.xml has location permissions

---

*This report is your single source of truth. Keep it updated!*
