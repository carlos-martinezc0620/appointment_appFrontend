import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores de los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool _loading = false;
  // Loading -> interruptor visual
  // true -> Muestra un "Cargando..." y bloquea la UI.
  // false -> Muestra la pantalla normal

  @override
  void initState() {
    super.initState();
    _loadUserData();
  } // Aquí se cargan los datos del usuario al iniciar la página

  // Cargar datoos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    print('Obteniendo perfil de usuario...');
    final doc = await _firestore.collection('users').doc(user.uid).get();
    print('Perfil obtenido correctamente');

    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      telefonoController.text = data['telefono'] ?? '';
      enfermedadesController.text = data['enfermedades'] ?? '';
      nicknameController.text = data['nickname'] ?? '';
    }
  }

  // Guardar datos del usuario en Firestore
  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    await _firestore.collection('users').doc(user.uid).set({
      'nombre': nombreController.text.trim(),
      'telefono': telefonoController.text.trim(),
      'enfermedades': enfermedadesController.text.trim(),
      'nickname': nicknameController.text.trim(),
      'email': user.email,
      'uid': user.uid,
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información guardada exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Correo: ${user?.email ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(labelText: 'Nickname'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: enfermedadesController,
                      decoration: const InputDecoration(
                        labelText: 'Enfermedades',
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text('Guardar información'),
                    ),

                    const SizedBox(height: 30),

                    // Botón para volver al menú principal
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.home,
                          (route) => false, //Elimina todas las rutas anteriores
                        );
                      },
                      child: const Text('Volver al menú principal'),
                    ),

                    const SizedBox(height: 20),
                    // Botón para cerrar sesión
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacementNamed(context, Routes.login);
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
