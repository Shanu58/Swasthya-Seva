import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/medicine_model.dart';
import '../models/medicine_detail_model.dart';
import '../models/my_medicine_model.dart';
import '../models/safety_result_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';

// ---------------------------------------------------------------------------
// Services - single instances shared across the app.
// ---------------------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  ref.onDispose(service.dispose);
  return service;
});

/// The concrete [VoiceService] implementation lives here and ONLY here.
/// To plug in Saaras V3 / Sarvam AI later, replace [DeviceTtsVoiceService]
/// with the new implementation - no screen changes needed.
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = DeviceTtsVoiceService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Language selection - persisted locally.
// ---------------------------------------------------------------------------

class LanguageNotifier extends StateNotifier<String> {
  final StorageService _storage;
  LanguageNotifier(this._storage) : super('en') {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.getLanguageCode();
    if (saved != null) state = saved;
  }

  Future<void> select(String code) async {
    state = code;
    await _storage.saveLanguageCode(code);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.watch(storageServiceProvider));
});

/// True once the user has explicitly picked a language, so Splash knows
/// whether to route to LanguageScreen or straight past it. Kept simple:
/// we just check SharedPreferences directly rather than adding another
/// notifier.
final hasSelectedLanguageProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final code = await storage.getLanguageCode();
  return code != null;
});

// ---------------------------------------------------------------------------
// Auth / guest session.
// ---------------------------------------------------------------------------

class SessionState {
  final bool isGuest;
  final int? userId;
  final String? userName;

  const SessionState({
    required this.isGuest,
    this.userId,
    this.userName,
  });

  bool get isSignedIn {
    return isGuest || userId != null;
  }

  bool get hasRealAccount {
    return userId != null;
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final StorageService _storage;

  SessionNotifier(this._storage)
      : super(
          const SessionState(
            isGuest: false,
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    final isGuest = await _storage.isGuestSession();
    final userId = await _storage.getUserId();
    final userName = await _storage.getUserName();

    state = SessionState(
      isGuest: isGuest,
      userId: userId,
      userName: userName,
    );
  }

  Future<void> continueAsGuest() async {
    await _storage.setGuestSession(true);

    state = const SessionState(
      isGuest: true,
    );
  }

  Future<void> signIn({
    required int userId,
    required String userName,
  }) async {
    await _storage.setGuestSession(false);
    await _storage.saveUserId(userId);
    await _storage.saveUserName(userName);

    state = SessionState(
      isGuest: false,
      userId: userId,
      userName: userName,
    );
  }

  Future<void> signOut() async {
    await _storage.clearSession();

    state = const SessionState(
      isGuest: false,
    );
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(
    ref.watch(storageServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Medicine scan / identification flow.
// ---------------------------------------------------------------------------

/// Holds the most recently identified medicine so the Identification and
/// Information screens can share it without re-fetching.
final currentMedicineProvider = StateProvider<Medicine?>((ref) => null);

final identifyMedicineProvider =
    FutureProvider.family<Medicine, File>((ref, imageFile) async {
  final api = ref.watch(apiServiceProvider);
  final medicine = await api.identifyMedicine(imageFile);
  ref.read(currentMedicineProvider.notifier).state = medicine;
  return medicine;
});

final medicineDetailProvider =
    FutureProvider.family<MedicineDetail, String>((ref, medicineId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMedicineDetail(medicineId);
});

// ---------------------------------------------------------------------------
// My Medicines.
// ---------------------------------------------------------------------------

final myMedicinesProvider = FutureProvider<List<MyMedicine>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getMyMedicines();
});

// ---------------------------------------------------------------------------
// Safety / interaction check.
// ---------------------------------------------------------------------------

final safetyCheckProvider = FutureProvider.autoDispose<SafetyResult>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.checkInteractions();
});

// ---------------------------------------------------------------------------
// Theme selection - persisted locally.
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage)
      : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final savedMode =
        await _storage.getThemeMode();

    if (savedMode == null) return;

    switch (savedMode) {
      case 'light':
        state = ThemeMode.light;
        break;

      case 'dark':
        state = ThemeMode.dark;
        break;

      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    state = mode;

    await _storage.saveThemeMode(
      mode.name,
    );
  }
Future<void> toggle() async {
  if (state == ThemeMode.dark) {
    await setThemeMode(
      ThemeMode.light,
    );
  } else {
    await setThemeMode(
      ThemeMode.dark,
    );
  }
}

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(
        ThemeMode.light,
      );
    } else {
      await setThemeMode(
        ThemeMode.dark,
      );
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<
        ThemeModeNotifier,
        ThemeMode
    >(
  (ref) {
    return ThemeModeNotifier(
      ref.watch(
        storageServiceProvider,
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// Misc.
// ---------------------------------------------------------------------------

final appLanguageObjectProvider = Provider<AppLanguage>((ref) {
  final code = ref.watch(languageProvider);
  return AppLanguages.byCode(code);
});
