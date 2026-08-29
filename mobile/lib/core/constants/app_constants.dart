/// Central place for app-wide constants.
///
/// Nothing in this file should leak UI concerns - it's pure configuration
/// so screens and services can stay decoupled from magic strings/numbers.
library app_constants;

class AppConstants {
  AppConstants._();

  static const String appName = 'Swasthya Seva';
  static const String appTagline = 'Verify. Understand. Stay Safe.';

  /// Base URL of the deployed FastAPI backend.
  static const String apiBaseUrl = 'https://swasthya-seva-api.onrender.com';

  static const Duration apiTimeout = Duration(seconds: 20);

  /// Set to false to use the deployed FastAPI backend.
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
