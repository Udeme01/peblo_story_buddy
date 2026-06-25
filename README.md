# 🤖 AI Story Buddy — Peblo Flutter Intern Challenge

A gamified, child-friendly Flutter app that reads an interactive story aloud using ElevenLabs AI voice, then presents a data-driven quiz with animated feedback.

Built by **Udeme Emmanuel** | Flutter Developer Intern Challenge Submission

---

## 🔐 API Key Note - NB;

For the purposes of this submission, the ElevenLabs API key is hardcoded directly in `story_provider.dart` so reviewers can clone and run the project immediately without any setup.

In a production environment, this would be moved to a `.env` file using `flutter_dotenv` and excluded from version control via `.gitignore`:

```dart
'xi-api-key': dotenv.env['ELEVENLABS_API_KEY'] ?? '',
```

The `.env` file would never be committed — only shared securely with team members.

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

| State     | UI Behaviour                                                        |
| --------- | ------------------------------------------------------------------- |
| `loading` | Button shows `CircularProgressIndicator` + "Generating AI Voice..." |
| `playing` | Button shows pause icon + "Playing..."                              |
| `error`   | Inline error banner shown, state resets to `idle` for retry         |

Errors are caught in a `try/catch` block:

```dart
} catch (e) {
  state = state.copyWith(
    status: StoryState.idle,
    errorMessage: 'Connection failed. Check your internet.',
  );
}
```

The `ref.listen` in `StoryScreen` surfaces the error message to the user without blocking the UI. A kid-friendly inline error banner with a retry prompt replaces the dismissed snackbar for better UX.

---

## ⚡ Performance Profiling

**Target:** 60fps on mid-range Android (~3GB RAM) — tested on Samsung Galaxy S8 (Android 9, API 28).

**What was measured:**

- Frame rendering time using Flutter DevTools → Performance tab
- Widget rebuild frequency using `debugPrintRebuildDirtyWidgets`

**What was changed:**

- Moved from `StatefulWidget` + `setState` to `ConsumerStatefulWidget` + Riverpod, so only widgets that watch specific state slices rebuild
- Confetti and shake animations use `AnimationController` which runs on a separate raster thread — does not block the UI thread
- `ref.listen` used for side effects (confetti trigger) instead of rebuilding the widget tree

**Result:** Animations run smoothly at 60fps. No jank observed during confetti burst or shake animation on the S8.

---

## 📱 Lightweight Optimization for Mid-Range Devices

- **No heavy image assets** — buddy character uses emoji rendered natively (zero memory overhead)
- **Audio played from memory bytes** — no temp file writes to disk during playback
- **`const` constructors** used throughout for static widgets — Flutter skips rebuilding them entirely
- **`SingleChildScrollView`** used instead of `ListView` for simple single-screen content — lower overhead
- **ElevenLabs `eleven_turbo_v2_5` model** selected — fastest, lowest latency model available

---

## 🤖 AI Usage & Judgment

I used **Claude (Anthropic)** selectively during this project, primarily as a sounding board and debugging aid:

- Validating my Riverpod provider structure after I'd already drafted it
- Investigating the ElevenLabs 402 error. I identified it was an account tier issue, and used Claude to confirm the exact API error response format
- Discussing the shake animation approach. I had the `TweenSequence` idea, and used Claude to sanity-check the weight values

The core architecture, UI design, state machine, and animation decisions were my own. Claude was useful for speeding up research and catching blind spots.

**One suggestion I rejected:**
During development, AI suggested replacing ElevenLabs with `flutter_tts` (native device TTS) as a simpler alternative. I pushed back on this because the quality difference is significant for a children's product — ElevenLabs produces a warmer, more expressive voice that is far more engaging for kids aged 6–10, which is core to Peblo's mission. The brief listed ElevenLabs as a bonus integration, so I felt the extra complexity was worth it for the experience quality. (I kept ElevenLabs and resolved the API issues instead).

**What didn't work:**
My initial approach was to suppress the `402 Payment Required` error silently and fall back to a retry without surfacing details to the user. This caused confusion during testing, the button would reset with no explanation, making it look like a bug rather than an account issue. I fixed this by logging the full ElevenLabs error response body and displaying a clear, friendly error message inline on the screen, which made the failure state obvious and actionable for both the user and during debugging.

---

## 📁 Project Structure - can be improved on later!

```
lib/
  main.dart                        # App entry point, ProviderScope, theme
  providers/
    story_provider.dart            # Riverpod Notifier — all app state & business logic
  screens/
    splash_screen.dart             # Branded loading screen with cycling images
    story_screen.dart              # Story view + quiz view + animations
```

---

## 🚀 How to Run

```bash
git clone https://github.com/Udeme01/peblo_story_buddy.git
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
