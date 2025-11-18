import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({super.key});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _doctorId; // Ahora será el UID REAL del doctor

  // -------------------------------------------------------------
  // GUARDAR CITA
  // -------------------------------------------------------------
  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _doctorId == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Crear documento
    final docRef = await FirebaseFirestore.instance
        .collection('appointments')
        .add({
          'motivo': _motivoController.text.trim(),
          'doctorId': _doctorId,
          'patientId': user.uid,
          'fechaHora': Timestamp.fromDate(newDateTime),
          'createdAt': Timestamp.now(),
        });

    // Guardar id del documento
    await docRef.update({'id': docRef.id});

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita creada correctamente')));

    Navigator.pop(context);
  }

  // -------------------------------------------------------------
  // PICKERS
  // -------------------------------------------------------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // -------------------------------------------------------------
  // FORMATOS DE FECHA Y HORA
  // -------------------------------------------------------------
  String getFormattedDate() {
    if (_selectedDate == null) return 'Seleccionar fecha';
    return 'Fecha: ${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  String getFormattedTime() {
    if (_selectedTime == null) return 'Seleccionar hora';
    final hour = _selectedTime!.hour.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    return 'Hora: $hour:$minute';
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: const Color(0xFF5AA9E6),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "Detalles de la cita",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4965),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // -------------------------------------------------------------
                  // MOTIVO
                  // -------------------------------------------------------------
                  TextFormField(
                    controller: _motivoController,
                    decoration: InputDecoration(
                      labelText: 'Motivo de la cita',
                      prefixIcon: const Icon(Icons.edit_calendar_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------------------
                  // SELECTOR DE DOCTOR (UID REAL)
                  // -------------------------------------------------------------
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .where('rol', isEqualTo: 'doctor')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Text("No hay doctores registrados");
                      }

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Seleccionar doctor',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final nombre = data['nombre'] ?? 'Sin nombre';
                          final especialidad =
                              data['especialidad'] ?? 'Sin especialidad';
                          final uid = data['uid'] ?? doc.id;

                          return DropdownMenuItem<String>(
                            value: uid,
                            child: Text(
                              "Dr. $nombre – $especialidad",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _doctorId = value);
                        },
                        validator: (v) =>
                            v == null ? 'Seleccione un doctor' : null,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------------------
                  // FECHA
                  // -------------------------------------------------------------
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white,
                    title: Text(getFormattedDate()),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF5AA9E6),
                    ),
                    onTap: _pickDate,
                  ),

                  const SizedBox(height: 8),

                  // -------------------------------------------------------------
                  // HORA
                  // -------------------------------------------------------------
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white,
                    title: Text(getFormattedTime()),
                    leading: const Icon(
                      Icons.access_time,
                      color: Color(0xFF5AA9E6),
                    ),
                    onTap: _pickTime,
                  ),

                  const SizedBox(height: 25),

                  // -------------------------------------------------------------
                  // BOTÓN GUARDAR
                  // -------------------------------------------------------------
                  ElevatedButton.icon(
                    onPressed: _saveAppointment,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar Cita'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AA9E6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
