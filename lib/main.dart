import 'package:flutter/material.dart';

import 'screens/main_screen.dart';

void main() {
  runApp(const FasalXApp());
}

class FasalXApp extends StatelessWidget {
  const FasalXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FasalX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
