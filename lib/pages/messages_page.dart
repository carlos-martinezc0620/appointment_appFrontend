import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  // 🔹 Modelo simple dentro del mismo archivo (para no crear más archivos)
  List<Map<String, dynamic>> get conversations => [
    {
      'title': 'Chat con Ana',
      'messages': [
        {'sender': 'Tú', 'text': 'Hola Ana, ¿cómo estás?'},
        {'sender': 'Ana', 'text': 'Todo bien, ¿y tú?'},
      ],
    },
    {
      'title': 'Chat con Carlos',
      'messages': [
        {'sender': 'Carlos', 'text': '¿Llegaste a la cita?'},
        {'sender': 'Tú', 'text': 'Sí, ya estoy esperando.'},
        {'sender': 'Carlos', 'text': 'Perfecto, llego en 5 minutos.'},
        {'sender': 'Tú', 'text': 'Ok, te espero.'},
        {'sender': 'Carlos', 'text': 'Ya estoy aquí.'},
        {'sender': 'Tú', 'text': 'Excelente, vamos a entrar.'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mensajes")),

      // 🔹 Si no hay mensajes, muestra tu texto original
      body: conversations.isEmpty
          ? const Center(
              child: Text(
                "No tienes un mensaje todavía.",
                style: TextStyle(fontSize: 16),
              ),
            )
          // 🔹 Si hay conversaciones, las mostramos dinámicamente
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final chat = conversations[index];
                final messages = chat['messages'] as List<Map<String, String>>;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      chat['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${messages.length} mensajes'),
                    children: List.generate(messages.length, (msgIndex) {
                      final msg = messages[msgIndex];
                      return ListTile(
                        title: Text('${msg['sender']}: ${msg['text']}'),
                      );
                    }),
                  ),
                );
              },
            ),
    );
  }
}
