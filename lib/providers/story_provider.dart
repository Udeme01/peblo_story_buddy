import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

// ─── App States ───────────────────────────────────────────────
enum StoryState { idle, loading, playing, quiz, wrong, success }

// ─── Quiz Model ───────────────────────────────────────────────
class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }
}

// ─── App State Class ──────────────────────────────────────────
class StoryAppState {
  final StoryState status;
  final String? selectedAnswer;
  final String? errorMessage;

  const StoryAppState({
    this.status = StoryState.idle,
    this.selectedAnswer,
    this.errorMessage,
  });

  StoryAppState copyWith({
    StoryState? status,
    String? selectedAnswer,
    String? errorMessage,
  }) {
    return StoryAppState(
      status: status ?? this.status,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Story Notifier ───────────────────────────────────────────
class StoryNotifier extends Notifier<StoryAppState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<int>? _cachedAudioBytes;

  final QuizQuestion quiz = QuizQuestion.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  });

  @override
  StoryAppState build() {
    // Listen to audio completion
    _audioPlayer.onPlayerComplete.listen((_) {
      state = state.copyWith(status: StoryState.quiz);
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.playing) {
        state = state.copyWith(status: StoryState.playing);
      }
    });

    // Dispose audio player when provider is disposed
    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    return const StoryAppState();
  }

  Future<void> readStory(String text) async {
    if (state.status == StoryState.loading ||
        state.status == StoryState.playing)
      return;

    state = state.copyWith(status: StoryState.loading, errorMessage: null);

    try {
      List<int> audioBytes;

      if (_cachedAudioBytes != null) {
        audioBytes = _cachedAudioBytes!;
      } else {
        final url = Uri.parse(
          'https://api.elevenlabs.io/v1/text-to-speech/5aPpMr0Bay4i0kI60SZW',
        );
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'xi-api-key': 'sk_360a36ae5c67e274ac152f31ce47051f7c8fc9be3efbffe6',
            'Accept': 'audio/mpeg',
          },
          body: jsonEncode({
            'text': text,
            'model_id': 'eleven_turbo_v2_5',
            'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
          }),
        );

        // if (response.statusCode != 200) {
        //   state = state.copyWith(
        //     status: StoryState.idle,
        //     errorMessage: 'Audio error ${response.statusCode}. Try again.',
        //   );
        //   return;
        // }

        if (response.statusCode != 200) {
          // Add this line:
          print('ElevenLabs error body: ${response.body}');

          state = state.copyWith(
            status: StoryState.idle,
            errorMessage: 'Audio error ${response.statusCode}. Try again.',
          );
          return;
        }

        _cachedAudioBytes = response.bodyBytes;
        audioBytes = _cachedAudioBytes!;
      }

      await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
      ;
    } catch (e) {
      state = state.copyWith(
        status: StoryState.idle,
        errorMessage: 'Connection failed. Check your internet.',
      );
    }
  }

  Future<void> pauseStory() async {
    await _audioPlayer.pause();
    state = state.copyWith(status: StoryState.idle);
  }

  // void checkAnswer(String selected) async {
  //   if (state.status == StoryState.success) return;

  //   state = state.copyWith(selectedAnswer: selected);

  //   if (selected == quiz.answer) {
  //     state = state.copyWith(status: StoryState.success);
  //   } else {
  //     state = state.copyWith(status: StoryState.wrong);
  //     await Future.delayed(const Duration(milliseconds: 600));
  //     state = state.copyWith(status: StoryState.quiz, selectedAnswer: null);
  //   }
  // }
  // In story_provider.dart
  void checkAnswer(String selected) async {
    if (state.status == StoryState.success) return;

    state = state.copyWith(selectedAnswer: selected);

    if (selected == quiz.answer) {
      state = state.copyWith(status: StoryState.success);
    } else {
      state = state.copyWith(status: StoryState.wrong);
      await Future.delayed(
        const Duration(milliseconds: 700),
      ); // slightly > 600ms animation
      state = state.copyWith(status: StoryState.quiz, selectedAnswer: null);
    }
  }

  void reset() {
    _audioPlayer.stop();
    state = const StoryAppState();
  }
}

// ─── Provider ─────────────────────────────────────────────────
final storyProvider = NotifierProvider<StoryNotifier, StoryAppState>(() {
  return StoryNotifier();
});
