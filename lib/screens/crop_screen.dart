import 'package:flutter/material.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Crops',
      icon: Icons.grass,
      message: 'Crop tracking will appear here.',
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
