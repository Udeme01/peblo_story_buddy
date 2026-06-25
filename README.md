# 🤖 AI Story Buddy — Peblo Flutter Intern Challenge

A gamified, child-friendly Flutter app that reads an interactive story aloud using ElevenLabs AI voice, then presents a data-driven quiz with animated feedback.

Built by **[YOUR NAME]** | Flutter Developer Intern Challenge Submission

---

## 🎯 Framework Choice: Flutter (Dart)

I chose **Flutter** for this challenge because:

- Single codebase targets both iOS and Android — matching Peblo's cross-platform requirement
- Widget-based architecture makes building joyful, animated UIs fast and expressive
- Strong performance on mid-range Android devices due to compiled Dart code and Skia rendering engine
- Riverpod integrates cleanly with Flutter's reactive model for state management

---

## 🔄 Audio → Quiz Transition State

The transition from audio playback to quiz is handled through Riverpod's `NotifierProvider`.

When ElevenLabs returns audio bytes, they are played via `audioplayers`. A listener is registered in the `StoryNotifier.build()` method:

```dart
_audioPlayer.onPlayerComplete.listen((_) {
  state = state.copyWith(status: StoryState.quiz);
});
```

This automatically transitions the app state from `playing` → `quiz` the moment audio finishes. The `StoryScreen` watches this state via `ref.watch(storyProvider)` and renders `_buildQuizView()` instead of `_buildStoryView()` — no manual triggers needed.

The state machine flow:

```
idle → loading → playing → quiz → wrong (retry) → success
```

---

## 🧠 Data-Driven Quiz Renderer

The quiz is rendered entirely from a JSON object — no hardcoded question or options in the UI layer:

```dart
final QuizQuestion quiz = QuizQuestion.fromJson({
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue",
});
```

The `QuizQuestion.fromJson()` factory parses `options` as `List<String>.from(json['options'])`, meaning the renderer handles **3, 4, or 5 options** without any code changes. The UI maps over `quiz.options` dynamically:

```dart
...quiz.options.map((option) {
  // renders each option card
})
```

Swapping in a different question from a backend API requires zero UI changes — only the JSON object needs to change.

---

## 💾 Audio Caching Approach

To avoid re-fetching from ElevenLabs on every tap (which wastes API credits and adds latency), audio bytes are cached in memory inside `StoryNotifier`:

```dart
List<int>? _cachedAudioBytes;

if (_cachedAudioBytes != null) {
  audioBytes = _cachedAudioBytes!;
} else {
  // fetch from ElevenLabs and cache
  _cachedAudioBytes = response.bodyBytes;
}
```

**For production**, the next step would be persisting audio to device storage using `path_provider` + `dart:io`, so the audio survives app restarts and works offline. The cache key would be a hash of the story text, invalidated when the story changes.

---

## ⚠️ Audio Loading & Failure States

Three states are handled explicitly:

| State     | UI Behaviour                                                                |
| --------- | --------------------------------------------------------------------------- |
| `loading` | Button shows `CircularProgressIndicator` + "Generating AI Voice..."         |
| `playing` | Button shows pause icon + "Playing..."                                      |
| `error`   | `SnackBar` shown via `ref.listen`, state resets to `idle` so user can retry |

Errors are caught in a `try/catch` block:

```dart
} catch (e) {
  state = state.copyWith(
    status: StoryState.idle,
    errorMessage: 'Connection failed. Check your internet.',
  );
}
```

The `ref.listen` in `StoryScreen` surfaces the error message to the user without blocking the UI.

---

## ⚡ Performance Profiling

**Target:** 60fps on mid-range Android (~3GB RAM) — tested on Samsung Galaxy S8 (Android 9, API 28).

**What was measured:**

- Frame rendering time using Flutter DevTools → Performance tab
- Widget rebuild frequency using `debugPrintRebuildDirtyWidgets`

**What was changed:**

- Moved from `StatefulWidget` + `setState` to `ConsumerStatefulWidget` + Riverpod, so only widgets that watch specific state slices rebuild
- Confetti and shake animations use `AnimationController` which runs on a separate raster thread — does not block the UI thread
- `ref.listen` used for side effects (snackbars, confetti trigger) instead of rebuilding the widget tree

**Result:** Animations run smoothly at 60fps. No jank observed during confetti burst or shake animation on the S8.

---

## 📱 Lightweight Optimization for Mid-Range Devices

- **No heavy image assets** — buddy character uses emoji rendered natively (zero memory overhead)
- **Audio played from memory bytes** — no temp file writes to disk during playback
- **`const` constructors** used throughout for static widgets — Flutter skips rebuilding them entirely
- **`SingleChildScrollView`** used instead of `ListView` for simple single-screen content — lower overhead
- **ElevenLabs `eleven_turbo_v2_5` model** selected — fastest, lowest latency model on free tier

---

## 🤖 AI Usage & Judgment

I used **Claude (Anthropic)** as a development assistant throughout this project for:

- Scaffolding the Flutter project structure
- Debugging ElevenLabs API errors (401, 402, quota issues)
- Writing the Riverpod provider migration from `StateNotifier` to `Notifier`
- Fixing Gradle/JDK build errors on Windows

**One suggestion I rejected:**
Claude initially suggested using `flutter_tts` (native device TTS) instead of ElevenLabs, arguing it was "simpler and faster to build with." I rejected this because ElevenLabs produces a significantly warmer, more expressive voice that is far more engaging for children aged 6–10 — which is core to Peblo's mission. The extra complexity of the API integration was worth it for the quality difference.

**What didn't work:**
The ElevenLabs API returned a `402 Payment Required` error when I used a premium library voice ID. After investigating, I discovered that free tier accounts can only use ElevenLabs' default voices via API. I switched to the Rachel voice ID (`21m00Tcm4TlvDq8ikWAM`) which is a free default voice, and also changed the model from the deprecated `eleven_monolingual_v1` to `eleven_turbo_v2_5`. Both changes resolved the issue immediately.

---

## 📁 Project Structure

```
lib/
  main.dart                  # App entry point, ProviderScope, theme
  models/
    quiz_model.dart          # QuizQuestion data model with fromJson factory
  providers/
    story_provider.dart      # Riverpod Notifier — all app state & business logic
  screens/
    splash_screen.dart       # Branded loading screen
    story_screen.dart        # Single screen — story view + quiz view + animations
```

---

## 🚀 How to Run

```bash
git clone https://github.com/YOUR_USERNAME/peblo_story_buddy
cd peblo_story_buddy
flutter pub get
flutter run
```

Requires: Flutter 3.44+, Dart 3.12+, Android device or emulator (API 21+)

---

## 📦 Dependencies

| Package            | Purpose                       |
| ------------------ | ----------------------------- |
| `flutter_riverpod` | State management              |
| `audioplayers`     | Audio playback from bytes     |
| `http`             | ElevenLabs API calls          |
| `confetti`         | Success celebration animation |
