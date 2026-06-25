// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../screens/story_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Timer(const Duration(seconds: 5), () {
//       // 10 seconds is usually too long for users; 3-5 is ideal
//       if (mounted) {
//         // Best practice check before using context across an async gap
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const StoryScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. Full-screen background image
//           Positioned.fill(
//             child: Image.asset(
//               "assets/images/peblo1.webp",
//               fit: BoxFit.cover, // Stretch & crop to completely fill the screen
//             ),
//           ),

//           // 2. Semi-dark overlay (Optional, but highly recommended for text readability)
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withValues(
//                 alpha: 0.4,
//               ), // Darkens background so white text pops
//             ),
//           ),

//           // 3. Foreground content
//           SafeArea(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment
//                     .end, // Pushes text beneath the center/towards bottom
//                 children: [
//                   const Text(
//                     "Peblo Story Buddy",
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   const Text(
//                     "Loading your stories...",
//                     style: TextStyle(fontSize: 16, color: Colors.white70),
//                   ),

//                   const SizedBox(height: 30),

//                   const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),

//                   const SizedBox(
//                     height: 50,
//                   ), // Gives breathing room at the bottom of the screen
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/story_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _images = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
    'assets/images/image5.jpg',
    'assets/images/image6.jpg',
    'assets/images/image7.jpg',
    'assets/images/image8.jpg',
    'assets/images/image9.jpg',
  ];

  int _currentIndex = 0;
  Timer? _imageTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Cycle images every 0.5 second
    _imageTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });

    // Navigate after 10 seconds
    _navTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StoryScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated background image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Image.asset(
                _images[_currentIndex],
                key: ValueKey(_currentIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // 2. Semi-dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),

          // 3. Foreground content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
