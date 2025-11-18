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
      setState(() => _selectedIndex = 0);
    } else if (index == 2) {
      await Navigator.pushNamed(context, Routes.settings);
      setState(() => _selectedIndex = 0);
    }
  }

  Future<String> _getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return 'Usuario';

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) return 'Usuario';

    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['nickname'] ?? data?['nombreCompleto'] ?? 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        String nombre = '...';
        if (snapshot.connectionState == ConnectionState.waiting) {
          nombre = 'Cargando...';
        } else if (snapshot.hasError) {
          nombre = 'Error';
        } else if (snapshot.hasData) {
          nombre = snapshot.data ?? 'Usuario';
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6FBFF),
          appBar: AppBar(
            title: const Text(
              "Inicio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.lightBlueAccent,
            elevation: 2,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Encabezado con saludo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.lightBlueAccent,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "¡Hola, $nombre!\n¿En qué podemos ayudarte hoy?",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Botones principales
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.calendar_month,
                      label: "Agendar Cita",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentFormPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.event_available,
                      label: "Ver mis Citas",
                      onTap: () {
                        Navigator.pushNamed(context, '/appointments');
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.health_and_safety,
                      label: "Consejos Médicos",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text("Consejos Médicos"),
                            content: const Text(
                              "Recuerda hidratarte, dormir bien y evitar el estrés. "
                              "Si presentas dolor leve, aplica compresas tibias y consulta a tu médico.",
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
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Especialistas disponibles",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Lista de especialistas
                Column(
                  children: especialistas
                      .map(
                        (esp) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_outline,
                              color: Colors.lightBlueAccent,
                            ),
                            title: Text(
                              esp,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onTap: () {},
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 25),

                // Sección inferior informativa
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Médicos destacados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Nuestros especialistas certificados están listos para atenderte "
                        "con el mejor cuidado. ¡Agenda tu cita hoy!",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra inferior
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.lightBlueAccent,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 170,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.lightBlueAccent,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
