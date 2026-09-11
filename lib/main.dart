import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ChineseStudyApp());
}

class ChineseStudyApp extends StatelessWidget {
  const ChineseStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese Study',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: const HomeScreen(),
    );
  }
}
