import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicSettingsPage extends StatefulWidget {
  final String doctorId;

  const MedicSettingsPage({super.key, required this.doctorId});

  @override
  State<MedicSettingsPage> createState() => _MedicSettingsPageState();
}

class _MedicSettingsPageState extends State<MedicSettingsPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.doctorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nombreController.text = data['nombre'] ?? '';
        especialidadController.text = data['especialidad'] ?? '';
      }
    } catch (e) {
      print("Error al cargar datos del doctor: $e");
    }

    setState(() {
      cargando = false;
    });
  }

  Future<void> guardarCambios() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.doctorId)
          .update({
            'nombre': nombreController.text,
            'especialidad': especialidadController.text,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cambios guardados correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar cambios: $e")));
    }
  }

  /// 🔥 FUNCIÓN PARA CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    // 🔥 Te lleva al login limpiando el historial
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // O la ruta que uses para login
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración del Doctor")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Editar perfil",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: especialidadController,
                  decoration: const InputDecoration(
                    labelText: "Especialidad",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: guardarCambios,
                  child: const Text("Guardar Cambios"),
                ),

                const SizedBox(height: 40),

                // 🔥 BOTÓN DE CERRAR SESIÓN
                ElevatedButton.icon(
                  onPressed: cerrarSesion,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
