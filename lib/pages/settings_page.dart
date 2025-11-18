import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF), // Fondo claro azul
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5AA9E6),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Ajustes de tu cuenta",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B4965),
              ),
            ),
            const SizedBox(height: 15),

            // Opción de perfil
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF5AA9E6)),
                title: const Text('Perfil'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.pushNamed(context, Routes.profile);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Opción de privacidad
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.lock, color: Color(0xFF5AA9E6)),
                title: const Text('Privacidad'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.pushNamed(context, Routes.privacy);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Opción de sobre nosotros
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF5AA9E6)),
                title: const Text('Sobre nosotros'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.pushNamed(context, Routes.about);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Opción de cerrar sesión
            Card(
              color: const Color(0xFFE63946),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
