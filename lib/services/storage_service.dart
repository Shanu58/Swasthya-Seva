import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences. Keeps key names in one place and
/// keeps the rest of the app from depending on the shared_preferences
/// package directly.
class StorageService {
  static const _kLanguageCode = 'selected_language_code';
  static const _kIsGuest = 'is_guest_session';
  static const _kUserName = 'user_name';

  Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageCode, code);
  }

  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguageCode);
  }

  Future<void> setGuestSession(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsGuest, isGuest);
  }

  Future<bool> isGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsGuest) ?? false;
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIsGuest);
    await prefs.remove(_kUserName);
  }
}
