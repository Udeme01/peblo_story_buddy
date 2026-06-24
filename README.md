# peblo_story_buddy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## screen flow

Splash Screen
      ↓
Story Screen
      ↓
Tap "Read Me a Story"
      ↓
Loading State
      ↓
TTS starts speaking
      ↓
Audio finishes
      ↓
Animated reveal of quiz
      ↓
Wrong answer → Shake card
Correct answer → Confetti + Happy buddy

I'd personally build the challenge in this order:
Phase 1

✅ Splash screen

Phase 2

✅ Main Story Screen UI

AI buddy image
Story card
Read Story button
Phase 3

✅ Integrate flutter_tts

States:

enum StoryStatus {
  idle,
  loading,
  speaking,
  completed,
  error
}
Phase 4

✅ Quiz model from JSON

class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}

Nothing will be hardcoded.

Phase 5

Wrong answer

Add:

shake: ^2.2.0

Wrong answer:

card shakes
haptic vibration
HapticFeedback.mediumImpact();
Phase 6

Success animation

Add:

confetti: ^0.8.0

Correct answer:

confetti 🎉
robot changes to happy image
success message
Phase 7

Performance

Use:

ConsumerWidget

instead of rebuilding the whole page.

Use:

AnimatedOpacity
AnimatedSwitcher

for the quiz reveal.

Packages I'd use
flutter_riverpod:
flutter_tts:
confetti:
shake:
google_fonts:
lottie: