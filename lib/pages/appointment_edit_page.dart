import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentEditPage extends StatefulWidget {
  final String docId;
  const AppointmentEditPage({required this.docId, super.key});

  @override
  State<AppointmentEditPage> createState() => _AppointmentEditPageState();
}

class _AppointmentEditPageState extends State<AppointmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _doctorId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.docId)
        .get();
    final data = doc.data()!;
    setState(() {
      _motivoController.text = data['motivo'] ?? '';
      final fecha = (data['fechaHora'] as Timestamp).toDate();
      _selectedDate = fecha;
      _selectedTime = TimeOfDay(hour: fecha.hour, minute: fecha.minute);
      _doctorId = data['doctorId'];
      _loading = false;
    });
  }

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

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _doctorId == null)
      return;

    final newDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.docId)
        .update({
          'motivo': _motivoController.text.trim(),
          'doctorId': _doctorId,
          'fechaHora': Timestamp.fromDate(newDateTime),
          'updatedAt': Timestamp.now(),
        });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita actualizada')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _doctorId,
                onChanged: (v) => _doctorId = v,
                decoration: const InputDecoration(labelText: 'Doctor ID'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : 'Fecha: ${_selectedDate!.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Seleccionar hora'
                      : 'Hora: ${_selectedTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveAppointment,
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
