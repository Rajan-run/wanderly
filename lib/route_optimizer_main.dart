import 'package:flutter/material.dart';
import 'package:wanderly_android/pages/route_optimizer_page.dart';

void main() {
  runApp(const RouteOptimizerApp());
}

class RouteOptimizerApp extends StatelessWidget {
  const RouteOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderly Route Optimizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RouteOptimizerPage(),
    );
  }
}
