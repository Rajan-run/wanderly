import 'package:flutter/material.dart';
// import 'screen/splash_screen.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const WanderlyApp());
}

class WanderlyApp extends StatelessWidget {
  const WanderlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderly.ai',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        // '/home': (context) => const HomeScreen(),
      },
    );
  }
}