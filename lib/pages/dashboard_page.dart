import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'medic_settings_page.dart';

class DashboardPage extends StatefulWidget {
  final String doctorId; // UID real del doctor autenticado

  const DashboardPage({super.key, required this.doctorId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardHome(doctorId: widget.doctorId), // Tab 0: indicadores
      const MessagesPage(), // Tab 1: Mensajes
      MedicSettingsPage(doctorId: widget.doctorId), // Tab 2: Configuración
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mensajes"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config"),
        ],
      ),
    );
  }
}

/// DashboardHome: muestra 3 indicadores en tiempo real usando streams de Firestore.
/// Ajustes posibles: nombre de colecciones/fields si tu modelo difiere.
class DashboardHome extends StatelessWidget {
  final String doctorId;

  const DashboardHome({super.key, required this.doctorId});

  // NOTE: Si tus citas están en otra colección (ej. doctor/{id}/citas),
  // cambia la consulta correspondiente abajo.
  Stream<QuerySnapshot<Map<String, dynamic>>> _totalCitasStream() {
    return FirebaseFirestore.instance
        .collection('citas') // <- cambia si tu colección se llama distinto
        .where('doctorId', isEqualTo: doctorId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _citasProximasStream() {
    final now = Timestamp.fromDate(DateTime.now());
    // Considera status si la usas (por ejemplo, 'cancelada' o 'completada')
    // Aquí filtramos por fecha >= ahora y por doctorId
    return FirebaseFirestore.instance
        .collection('citas')
        .where('doctorId', isEqualTo: doctorId)
        .where('fecha', isGreaterThanOrEqualTo: now)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _totalPacientesStream() {
    // Esto cuenta todos los usuarios con rol == "Paciente".
    // Si quieres contar sólo pacientes que tengan citas con este doctor,
    // habría que hacer una consulta distinta (agregación).
    return FirebaseFirestore.instance
        .collection('usuarios')
        .where('rol', isEqualTo: 'Paciente')
        .snapshots();
  }

  Widget _buildIndicator({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grid de 3 indicadores (responsive: 1 o 2 columnas según ancho)
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 28,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Dashboard del Doctor",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Indicadores
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    children: [
                      // Total citas creadas
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _totalCitasStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return _buildIndicator(
                              title: "Total de citas",
                              content: Text('Error: ${snap.error}'),
                            );
                          }
                          if (!snap.hasData) {
                            return _buildIndicator(
                              title: "Total de citas",
                              content: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final total = snap.data!.docs.length;
                          return _buildIndicator(
                            title: "Total de citas",
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$total',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.event_note, size: 36),
                              ],
                            ),
                          );
                        },
                      ),

                      // Citas próximas / pendientes
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _citasProximasStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return _buildIndicator(
                              title: "Citas próximas",
                              content: Text('Error: ${snap.error}'),
                            );
                          }
                          if (!snap.hasData) {
                            return _buildIndicator(
                              title: "Citas próximas",
                              content: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Si usas un campo "status" para diferenciar, filtra aquí:
                          // final pendientes = snap.data!.docs.where((d) => d.data()['status'] != 'cancelada').length;
                          final pendientes = snap.data!.docs.length;

                          return _buildIndicator(
                            title: "Citas próximas",
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$pendientes',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text('Pendientes / por venir'),
                                  ],
                                ),
                                const Icon(Icons.upcoming, size: 36),
                              ],
                            ),
                          );
                        },
                      ),

                      // Total pacientes registrados
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _totalPacientesStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return _buildIndicator(
                              title: "Total de pacientes",
                              content: Text('Error: ${snap.error}'),
                            );
                          }
                          if (!snap.hasData) {
                            return _buildIndicator(
                              title: "Total de pacientes",
                              content: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final totalPacientes = snap.data!.docs.length;
                          return _buildIndicator(
                            title: "Total de pacientes",
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$totalPacientes',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.people, size: 36),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Opcional: botón para recargar manualmente (no suele ser necesario con streams)
            ElevatedButton.icon(
              onPressed: () {
                // Forzar rebuild; normalmente los streams son suficientes.
                (context as Element).markNeedsBuild();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
