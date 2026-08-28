import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstraction over "speak this text in this language" so the UI layer
/// never talks to a concrete TTS/AI implementation directly.
///
/// Today [DeviceTtsVoiceService] uses the phone's built-in TTS engine so
/// the demo has real audio playback out of the box. When the Saaras V3 /
/// Sarvam AI multilingual voice stack is ready, add a
/// `SaarasVoiceService implements VoiceService` here and swap the
/// provider override in providers/app_providers.dart - no screen needs to
/// change.
abstract class VoiceService {
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();

  /// Emits true while audio is actively playing, false otherwise.
  Stream<bool> get isSpeakingStream;

  void dispose();
}

class DeviceTtsVoiceService implements VoiceService {
  final FlutterTts _tts = FlutterTts();
  final _speakingController = _BroadcastBoolController();

  DeviceTtsVoiceService() {
    _tts.setStartHandler(() => _speakingController.add(true));
    _tts.setCompletionHandler(() => _speakingController.add(false));
    _tts.setCancelHandler(() => _speakingController.add(false));
    _tts.setErrorHandler((_) => _speakingController.add(false));
  }

  /// Maps our app language codes to locale codes the device TTS engine
  /// understands. Falls back to English if a voice/locale isn't installed
  /// on the device - common on emulators/test devices without all Indian
  /// language voice packs.
  static const Map<String, String> _localeMap = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'bn': 'bn-IN',
    'or': 'or-IN',
    'te': 'te-IN',
  };

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    final locale = _localeMap[languageCode] ?? 'en-IN';
    try {
      await _tts.setLanguage(locale);
    } catch (_) {
      await _tts.setLanguage('en-IN');
    }
    await _tts.setSpeechRate(0.42); // slower for clarity - rural/elderly users
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Stream<bool> get isSpeakingStream => _speakingController.stream;

  @override
  void dispose() => _speakingController.close();
}

class _BroadcastBoolController {
  final _controller = StreamController<bool>.broadcast();
  void add(bool value) => _controller.add(value);
  Stream<bool> get stream => _controller.stream;
  void close() => _controller.close();
}
