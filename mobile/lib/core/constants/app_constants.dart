/// Central place for app-wide constants.
///
/// Nothing in this file should leak UI concerns - it's pure configuration
/// so screens and services can stay decoupled from magic strings/numbers.
library app_constants;

class AppConstants {
  AppConstants._();

  static const String appName = 'Swasthya Seva';
  static const String appTagline = 'Verify. Understand. Stay Safe.';

  /// Base URL of the FastAPI backend.
  ///
  /// This is intentionally the ONLY place the backend host is configured.
  /// For a physical device on the same network as your dev machine, replace
  /// 10.0.2.2 (Android emulator's alias for host localhost) with your
  /// machine's LAN IP, e.g. http://192.168.1.42:8000
  static const String apiBaseUrl = 'http://127.0.0.1:8000';

  static const Duration apiTimeout = Duration(seconds: 20);

  /// While the backend team wires up the real endpoints, the frontend runs
  /// entirely against [MockDataService] so the demo works end-to-end today.
  /// Flip this to `false` once the FastAPI backend + DB are reachable -
  /// no screen code needs to change, only this flag.
  static const bool useMockData = false;

  static const Duration splashDuration = Duration(seconds: 2);
}

/// A supported UI / voice-output language.
class AppLanguage {
  final String code; // BCP-47-ish code used by OCR/TTS/backend
  final String englishName;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });
}

class AppLanguages {
  AppLanguages._();

  static const List<AppLanguage> supported = [
    AppLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
    AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिंदी'),
    AppLanguage(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    AppLanguage(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
  ];

  static AppLanguage byCode(String code) {
    return supported.firstWhere(
      (l) => l.code == code,
      orElse: () => supported.first,
    );
  }
}
