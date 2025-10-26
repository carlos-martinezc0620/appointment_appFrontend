import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre Nosotros')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'DoctorAppointmentApp es un proyecto diseñado para facilitar la '
          'gestión de citas médicas, ofreciendo herramientas simples para '
          'pacientes y doctores.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
