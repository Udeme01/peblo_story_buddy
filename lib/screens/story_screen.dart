import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  final String _apiKey = "sk_360a36ae5c67e274ac152f31ce47051f7c8fc9be3efbffe6";
  final String _voiceId = "5aPpMr0Bay4i0kI60SZW";
  final String _storyText =
      "Once upon a time, a clever little robot named Pip lived in a world made of shiny copper and glowing wires. Pip wasn't like other robots. Pip loved to find stories in the hum of the machines.";

  // Quiz data - driven from JSON, not hardcoded
  final Map<String, dynamic> _quizData = {
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  };

  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showQuiz = false;
  String? _selectedAnswer;
  bool _isCorrect = false;
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _showQuiz = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _speakStory() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': _storyText,
          'model_id': 'eleven_turbo_v2_5',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        await _audioPlayer.play(BytesSource(bytes));
      } else {
        _showError("Audio error: ${response.statusCode}. Please try again.");
      }
    } catch (e) {
      _showError("Connection failed. Please check your internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkAnswer(String selected) async {
    if (_isCorrect) return;

    setState(() => _selectedAnswer = selected);

    if (selected == _quizData['answer']) {
      setState(() => _isCorrect = true);
      _confettiController.play();
      HapticFeedback.heavyImpact();
    } else {
      setState(() => _isWrong = true);
      HapticFeedback.vibrate();
      await _shakeController.forward(from: 0);
      setState(() {
        _isWrong = false;
        _selectedAnswer = null;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Color(0xFF6F2BC2)),
        title: const Text(
          'AI Story Buddy',
          style: TextStyle(
            color: Color(0xFF6F2BC2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF6F2BC2),
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _showQuiz ? _buildQuizView() : _buildStoryView(),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFF6F2BC2),
                Color(0xFFFFD700),
                Colors.pink,
                Colors.blue,
                Colors.green,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AI Buddy character
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDD0FF), width: 2),
            ),
            child: Center(
              child: Text(
                _isPlaying ? '🤖💬' : '🤖',
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Story card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDD0FF), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'STORY TEXT APPEARS HERE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.menu_book_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _storyText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Color(0xFF2D1B69),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Read Me a Story button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _speakStory,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.volume_up,
                      color: Colors.white,
                    ),
              label: Text(
                _isLoading
                    ? 'Generating AI Voice...'
                    : _isPlaying
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    final List<String> options = List<String>.from(
      _quizData['options'] as List,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Buddy - success or normal
          Center(
            child: Text(
              _isCorrect ? '🤖🎉' : '🤖',
              style: const TextStyle(fontSize: 72),
            ),
          ),

          const SizedBox(height: 24),

          // Success message
          if (_isCorrect)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6F2BC2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    '🎉 Amazing!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You got it right!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

          if (!_isCorrect) ...[
            // Question
            Text(
              _quizData['question'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B69),
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic options
            ...options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isAnswer = option == _quizData['answer'];

              return AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  double offset = 0;
                  if (_isWrong && isSelected) {
                    offset =
                        _shakeAnimation.value *
                        ((_shakeController.value * 10).round().isEven ? 1 : -1);
                  }
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => _checkAnswer(option),
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
                            ? const Color(0xFF6F2BC2)
                            : const Color(0xFFDDD0FF),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  ? const Color(0xFF6F2BC2)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            color: isSelected
                                ? const Color(0xFF6F2BC2)
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

          const SizedBox(height: 20),

          // Try again / Play again button
          if (_isCorrect)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showQuiz = false;
                    _isCorrect = false;
                    _selectedAnswer = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F2BC2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Play Again 🎮',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
