import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/story_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      // 10 seconds is usually too long for users; 3-5 is ideal
      if (mounted) {
        // Best practice check before using context across an async gap
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StoryScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/peblo1.webp",
              fit: BoxFit.cover, // Stretch & crop to completely fill the screen
            ),
          ),

          // 2. Semi-dark overlay (Optional, but highly recommended for text readability)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.4,
              ), // Darkens background so white text pops
            ),
          ),

          // 3. Foreground content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Pushes text beneath the center/towards bottom
                children: [
                  const Text(
                    "Peblo Story Buddy",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Loading your stories...",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),

                  const SizedBox(
                    height: 50,
                  ), // Gives breathing room at the bottom of the screen
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
