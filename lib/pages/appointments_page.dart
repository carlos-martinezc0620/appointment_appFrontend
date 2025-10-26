import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_edit_page.dart'; // Edición de agenda de citas

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String? _editingDocId;

  @override
  Widget build(BuildContext context) {
    // Si se está editando una cita, mostrar el formulario de edición
    return _editingDocId == null
        ? _buildListView()
        : AppointmentEditPage(
            docId: _editingDocId!,
            key: ValueKey(_editingDocId),
          );
  }

  Widget _buildListView() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final query = FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('fechaHora');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No tienes citas agendadas'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final fecha = (data['fechaHora'] as Timestamp).toDate();
              return ListTile(
                title: Text(data['motivo'] ?? 'Sin motivo'),
                subtitle: Text(
                  '${fecha.toLocal()} - Dr: ${data['doctorId'] ?? 'N/A'}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() => _editingDocId = doc.id);
                    } else if (value == 'delete') {
                      _confirmDelete(context, doc.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(docId)
                  .delete();
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cita eliminada')));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
