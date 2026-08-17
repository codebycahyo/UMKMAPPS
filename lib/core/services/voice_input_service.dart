import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class VoiceInputService {
  // Singleton pattern
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  
  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('onStatus: $status'),
        onError: (errorNotification) => debugPrint('onError: $errorNotification'),
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('Error initializing SpeechToText: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) {
      await init();
    }
    if (_isAvailable && !_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(localeId: 'id_ID'),
      );
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
