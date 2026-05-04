import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Health')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Check crop health',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Photo upload karein ya AI Help se fasal ki problem poochein.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add Crop Photo'),
          ),
        ],
      ),
    );
  }
}
