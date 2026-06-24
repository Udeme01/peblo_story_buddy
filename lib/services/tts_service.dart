import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool isInitialized = false;

  Future<void> init() async {
    if (isInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // slow enough for kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // slightly higher, friendlier
    isInitialized = true;
  }

  Future<void> speak(String text, {VoidCallback? onDone}) async {
    await init();
    _tts.setCompletionHandler(() {
      if (onDone != null) onDone();
    });
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
