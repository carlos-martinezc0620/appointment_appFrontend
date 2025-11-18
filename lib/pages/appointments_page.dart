import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_edit_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String? _editingDocId;

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: const Color(0xFF5AA9E6),
        centerTitle: true,
        elevation: 3,
      ),
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

          if (docs.isEmpty && _editingDocId != null) {
            setState(() => _editingDocId = null);
          }

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes citas agendadas',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1B4965),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                final data = doc.data() as Map<String, dynamic>;
                final fecha = (data['fechaHora'] as Timestamp).toDate();

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5AA9E6).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF5AA9E6),
                      ),
                    ),
                    title: Text(
                      data['motivo'] ?? 'Sin motivo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4965),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '${fecha.day.toString().padLeft(2, '0')}/'
                        '${fecha.month.toString().padLeft(2, '0')}/'
                        '${fecha.year} - '
                        '${fecha.hour.toString().padLeft(2, '0')}:'
                        '${fecha.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (value) {
                        if (value == 'edit') {
                          setState(() => _editingDocId = doc.id);
                        } else if (value == 'delete') {
                          _confirmDelete(context, doc.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar cita'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar cita'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Deseas cancelar esta cita?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAppointmentSafely(docId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointmentSafely(String docId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .delete();

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cita eliminada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar cita: $e')));
    }
  }
}
