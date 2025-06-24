import 'package:flutter/material.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const WanderlyApp());
}

class WanderlyApp extends StatelessWidget {
  const WanderlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}