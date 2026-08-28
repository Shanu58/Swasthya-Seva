# Swasthya Seva — Flutter Frontend

AI-powered medicine verification and safety app for rural India (SIH 2026).
This is the **Flutter mobile frontend only** — backend, database, OCR-matching
pipeline, and safety/interaction logic are owned by other developers.

## What's included

Full end-to-end demo flow, running entirely against realistic mock data that
mirrors the real A-Z Medicine Dataset of India (Dolo 650, Crocin 500,
Augmentin 625 Duo, Azithral 500, Pantop 40, Combiflam — real brand/manufacturer
names, not placeholders):

```
Splash → Language Selection → Sign In / Guest → Home → Scan Medicine →
Camera/Image Input → Identification Result → Verification + Info Screen →
Add to My Medicines → Safety/Interaction Result → Voice Playback
```

## Project structure

```
lib/
├── main.dart              # entry point, wraps app in ProviderScope
├── app.dart                # MaterialApp + theme + initial route
├── core/
│   ├── constants/          # app config, supported languages
│   └── theme/               # colors, typography, component themes
├── models/                  # data classes matching the API contract exactly
├── providers/                # all Riverpod providers (services + state)
├── services/
│   ├── api_service.dart      # real HTTP client for the FastAPI backend
│   ├── mock_data_service.dart# demo data source (real dataset values)
│   ├── storage_service.dart  # SharedPreferences wrapper
│   └── voice_service.dart    # VoiceService abstraction (device TTS today,
│                              # swap in Saaras V3 / Sarvam later)
├── screens/                  # one folder per flow step
└── widgets/                   # shared badges, buttons, section cards
```

## Getting it running

This container doesn't have the Flutter SDK installed, so the platform
folders (`android/`, `ios/`) aren't generated here. On your machine, with
Flutter installed:

```bash
cd swasthya_seva

# 1. Generate platform folders (safe — does not touch lib/ or pubspec.yaml)
flutter create .

# 2. Install dependencies
flutter pub get

# 3. Add camera + storage permissions for image_picker.
#    Open android/app/src/main/AndroidManifest.xml and add, inside <manifest>,
#    above <application>:
#
#    <uses-permission android:name="android.permission.CAMERA" />
#    <uses-feature android:name="android.hardware.camera" android:required="false" />

# 4. Run on an emulator or connected device
flutter run
```

## Switching from mock data to the real backend

Everything is already wired to the API contract — flipping one flag switches
every screen from mock data to real HTTP calls, with zero screen-level changes:

1. Open `lib/core/constants/app_constants.dart`
2. Set `useMockData = false`
3. Point `apiBaseUrl` at the FastAPI backend
   (`http://10.0.2.2:8000` is the Android emulator's alias for your machine's
   `localhost:8000`; use your machine's LAN IP for a physical device)

`ApiService` (`lib/services/api_service.dart`) then calls the real endpoints:

| Method                     | Endpoint                     |
|-----------------------------|-------------------------------|
| `identifyMedicine(image)`   | `POST /medicines/identify`    |
| `getMedicineDetail(id)`     | `GET /medicines/{id}`         |
| `getMyMedicines()`          | `GET /users/me/medicines`     |
| `addToMyMedicines(medicine)`| `POST /users/me/medicines`    |
| `checkInteractions()`       | `POST /safety/check`          |

## Notes on design decisions

- **State management**: Riverpod. Services are `Provider`s, session/language
  are `StateNotifierProvider`s, and all backend-facing data is
  `FutureProvider`/`FutureProvider.family` so screens get built-in
  loading/error/data states for free.
- **Safety logic stays on the backend.** `SafetyResultScreen` only renders
  the `SafetyResult` the backend computes (GREEN/YELLOW/RED) — no
  interaction/duplicate-ingredient logic exists in the Flutter code.
- **Voice playback** uses `flutter_tts` (device TTS) behind a `VoiceService`
  interface so it works for the demo today. Adding the real Saaras V3 /
  Sarvam AI multilingual voice stack later means writing one new class
  (`SaarasVoiceService implements VoiceService`) and changing a single
  provider override — no screen touches TTS directly.
- **Accessibility**: large buttons (56px min height), 17–18px body text,
  high-contrast color-coded badges, minimal steps per screen — per the
  rural-user accessibility requirement.
