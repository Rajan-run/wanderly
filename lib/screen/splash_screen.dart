import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _bgAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bgAnimation = CurvedAnimation(parent: _bgController, curve: Curves.easeIn);

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _contentAnimation = CurvedAnimation(parent: _contentController, curve: Curves.easeIn);

    _bgController.forward();
    // Start content fade-in after a short delay for a smooth effect
    Future.delayed(const Duration(milliseconds: 600), () {
      _contentController.forward();
    });

    // Navigate to HomeScreen after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fade-in GIF background
          FadeTransition(
            opacity: _bgAnimation,
            child: Image.asset(
              'assets/splash_bg.gif',
              fit: BoxFit.cover,
            ),
          ),
          // Optional: overlay for darkening the background
          FadeTransition(
            opacity: _bgAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Centered animated logo and app name
          Center(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Wanderly",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Travel. Explore. Discover.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}