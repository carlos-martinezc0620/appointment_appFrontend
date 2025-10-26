import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mensajes")),
      body: const Center(
        child: Text(
          "No tienes un mensaje todavía.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
