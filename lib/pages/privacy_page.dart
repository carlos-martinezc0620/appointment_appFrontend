import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'En esta aplicación, tu información personal se almacena de forma segura '
          'y solo se usa para fines de gestión de citas médicas.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
