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

    // 🔧 Evita errores si el documento fue eliminado
    if (!doc.exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cita ya no existe o fue eliminada')),
      );
      Navigator.pop(context);
      return;
    }

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
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6FBFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        title: const Text(
          'Editar Cita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5AA9E6),
        elevation: 3,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _motivoController,
                      decoration: InputDecoration(
                        labelText: 'Motivo',
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF5AA9E6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5AA9E6),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _doctorId,
                      onChanged: (v) => _doctorId = v,
                      decoration: InputDecoration(
                        labelText: 'ID del Doctor',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF5AA9E6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5AA9E6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF5AA9E6),
                      ),
                      title: Text(
                        _selectedDate == null
                            ? 'Seleccionar fecha'
                            : 'Fecha: ${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.year}',
                        style: const TextStyle(color: Color(0xFF1B4965)),
                      ),
                      onTap: _pickDate,
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: const Icon(
                        Icons.access_time_outlined,
                        color: Color(0xFF5AA9E6),
                      ),
                      title: Text(
                        _selectedTime == null
                            ? 'Seleccionar hora'
                            : 'Hora: ${_selectedTime!.format(context)}',
                        style: const TextStyle(color: Color(0xFF1B4965)),
                      ),
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _saveAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AA9E6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF5AA9E6).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
