import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';
import 'messages_page.dart';
import 'appointments_page.dart';
import 'appointment_form_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> especialistas = [
    "Cardiólogo",
    "Dermatólogo",
    "Pediatra",
    "Traumatólogo",
    "Nutriólogo",
  ];

  void _onItemTapped(int index) async {
    if (index == 1) {
      await Navigator.pushNamed(context, Routes.messages);
      setState(() => _selectedIndex = 0); // Volver a Inicio
    } else if (index == 2) {
      await Navigator.pushNamed(context, Routes.settings);
      setState(() => _selectedIndex = 0);
    }
  }

  Future<String> _getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return 'Usuario';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) return 'Usuario';

    final data = snapshot.data() as Map<String, dynamic>?;
    // Usa el nickname si existe, o el nombreCompleto si no
    return data?['nickname'] ?? data?['nombreCompleto'] ?? 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        String nombre = '...'; // texto temporal mientras carga

        if (snapshot.connectionState == ConnectionState.waiting) {
          nombre = 'Cargando...';
        } else if (snapshot.hasError) {
          nombre = 'Error';
        } else if (snapshot.hasData) {
          nombre = snapshot.data ?? 'Usuario';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Inicio"),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  "¡Hola, $nombre! ¿En qué podemos ayudarte?",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Botones principales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text("Agendar una Cita"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/appointments');
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text("Ver mis Citas"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Consejos Médicos"),
                            content: const Text(
                              "Recuerda hidratarte, dormir bien y evitar el estrés. "
                              "Si presentas dolor leve, puedes aplicar compresas tibias.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cerrar"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text("Consejos Médicos"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Especialistas disponibles:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Column(
                  children: especialistas
                      .map(
                        (esp) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(esp),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Sección adicional: médicos populares o servicios destacados",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Barra de navegación inferior
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Mensajes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Configuración',
              ),
            ],
          ),
        );
      },
    );
  }
}
