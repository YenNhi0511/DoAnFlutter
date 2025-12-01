import 'package:flutter_tts/flutter_tts.dart';

/// Service for Text-to-Speech functionality
class TextToSpeechService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    
    // Set language
    await _flutterTts!.setLanguage('en-US');
    
    // Set speech rate (0.0 to 1.0)
    await _flutterTts!.setSpeechRate(0.5);
    
    // Set volume (0.0 to 1.0)
    await _flutterTts!.setVolume(1.0);
    
    // Set pitch (0.5 to 2.0)
    await _flutterTts!.setPitch(1.0);

    // Set completion handler
    _flutterTts!.setCompletionHandler(() {
      _isSpeaking = false;
    });

    // Set error handler
    _flutterTts!.setErrorHandler((msg) {
      print('TTS Error: $msg');
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    if (text.isEmpty) return;

    _isSpeaking = true;
    await _flutterTts!.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isInitialized && _isSpeaking) {
      await _flutterTts!.stop();
      _isSpeaking = false;
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    if (_isInitialized && _isSpeaking) {
      await _flutterTts!.pause();
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set language
  Future<void> setLanguage(String language) async {
    if (_isInitialized) {
      await _flutterTts!.setLanguage(language);
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (_isInitialized) {
      await _flutterTts!.setSpeechRate(rate.clamp(0.0, 1.0));
    }
  }

  /// Dispose resources
  void dispose() {
    _flutterTts = null;
    _isInitialized = false;
    _isSpeaking = false;
  }
}

final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  final service = TextToSpeechService();
  service.initialize();
  return service;
});

