import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../providers/story_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const String storyText =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -16), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -16, end: 16), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 16, end: -16), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -16, end: 16), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 16, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleAnswerTap(String option, StoryNotifier notifier) async {
    final isCorrect = option == notifier.quiz.answer;

    if (isCorrect) {
      notifier.checkAnswer(option);
      _confettiController.play();
      HapticFeedback.heavyImpact();
    } else {
      notifier.checkAnswer(option); // sets status to wrong
      HapticFeedback.vibrate();
      await _shakeController.forward(from: 0);
      // state resets inside notifier after 600ms delay — matches animation duration
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(storyProvider.select((s) => s.status));
    final errorMessage = ref.watch(storyProvider.select((s) => s.errorMessage));
    final appState = ref.watch(storyProvider);
    final notifier = ref.read(storyProvider.notifier);
    final isQuiz =
        status == StoryState.quiz ||
        status == StoryState.wrong ||
        status == StoryState.success;

    // Show error snackbar if any
    ref.listen(storyProvider, (previous, next) {
      // Trigger confetti on success
      if (next.status == StoryState.success) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: const Color(0xFF6F2BC2),
      backgroundColor: const Color.fromARGB(255, 246, 236, 254),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text(
          'AI Story Buddy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          isQuiz
              ? _buildQuizView(appState, notifier)
              : _buildStoryView(status, notifier, errorMessage),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFFFFD700),
                Colors.pink,
                Colors.blue,
                Colors.green,
                Colors.white,
              ],
              numberOfParticles: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryView(
    StoryState status,
    StoryNotifier notifier,
    String? errorMessage,
  ) {
    final isLoading = status == StoryState.loading;
    final isPlaying = status == StoryState.playing;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6F2BC2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Image.asset(
            isPlaying ? 'assets/images/image1.jpg' : 'assets/images/image2.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // BOTTOM — white card with story + button
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Story card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0FF),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF6F2BC2,
                          ).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Pip's Story 🤖",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          storyText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Text('...', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Oops! Something went wrong. Tap the button to try again!',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : isPlaying
                          ? notifier.pauseStory
                          : () => notifier.readStory(storyText),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.volume_up,
                              color: Colors.white,
                            ),
                      label: Text(
                        isLoading
                            ? 'Generating AI Voice...'
                            : isPlaying
                            ? 'Playing...'
                            : 'Read Me a Story',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F2BC2),
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF6F2BC2,
                        ).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView(StoryAppState appState, StoryNotifier notifier) {
    final quiz = notifier.quiz;
    final isSuccess = appState.status == StoryState.success;
    final isWrong = appState.status == StoryState.wrong;
    final selectedAnswer = appState.selectedAnswer;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 253, 251, 255),
            Color.fromARGB(255, 253, 251, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(
              isSuccess
                  ? 'assets/images/image1.jpg'
                  : 'assets/images/image9.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // White bottom sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isSuccess) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F2BC2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '🎉 Amazing!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You got it right!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: notifier.reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F2BC2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Play Again',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (!isSuccess) ...[
                      const SizedBox(height: 8),
                      Text(
                        quiz.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B69),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dynamic options from JSON
                      ...quiz.options.map((option) {
                        final isSelected = selectedAnswer == option;

                        return AnimatedBuilder(
                          animation: _shakeAnimation,

                          builder: (context, child) {
                            final offset = (isWrong && isSelected)
                                ? _shakeAnimation.value
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },

                          child: GestureDetector(
                            onTap: () {
                              if (_shakeController.isAnimating) return;
                              _handleAnswerTap(option, notifier);
                            },

                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? (isWrong
                                            ? Colors.red
                                            : const Color(0xFF6F2BC2))
                                      : Colors.white,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: const Color(0xFF2D1B69),
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? (isWrong
                                                  ? Colors.red
                                                  : const Color(0xFF6F2BC2))
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? (isWrong
                                                ? Colors.red
                                                : const Color(0xFF6F2BC2))
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
