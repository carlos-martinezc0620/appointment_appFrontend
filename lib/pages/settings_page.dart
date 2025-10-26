import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          ListTile(
            title: const Text('Privacidad'),
            onTap: () {
              Navigator.pushNamed(context, Routes.privacy);
            },
          ),
          ListTile(
            title: const Text('Sobre nosotros'),
            onTap: () {
              Navigator.pushNamed(context, Routes.about);
            },
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
