import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'medic_settings_page.dart';

class DashboardPage extends StatefulWidget {
  final String doctorId;
  const DashboardPage({super.key, required this.doctorId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardHome(doctorId: widget.doctorId),
      const Center(child: Text("Mensajes")),
      MedicSettingsPage(doctorId: widget.doctorId), //  <-- YA AGREGADO
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
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

//
// ─────────────────────────────────────────────
//   DASHBOARD HOME — GRÁFICAS
// ─────────────────────────────────────────────
//

class DashboardHome extends StatefulWidget {
  final String doctorId;
  const DashboardHome({super.key, required this.doctorId});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  Stream<QuerySnapshot<Map<String, dynamic>>> _citasStream() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .snapshots();
  }

  static const List<String> _mesesText = [
    "",
    "Ene",
    "Feb",
    "Mar",
    "Abr",
    "May",
    "Jun",
    "Jul",
    "Ago",
    "Sep",
    "Oct",
    "Nov",
    "Dic",
  ];

  Map<String, int> _groupByMonth(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final Map<String, int> result = {};

    // Últimos 6 meses
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);
      result["${m.month}/${m.year}"] = 0;
    }

    // Contar citas de Firebase
    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;

      if (!data.containsKey('createdAt')) continue;
      if (data['createdAt'] is! Timestamp) continue;

      final date = (data['createdAt'] as Timestamp).toDate();
      final key = "${date.month}/${date.year}";

      if (result.containsKey(key)) {
        result[key] = result[key]! + 1;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Icon(Icons.analytics, size: 28, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Dashboard del Doctor",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        //
        // STREAM BUILDER
        //
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _citasStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final citasPorMes = _groupByMonth(docs);
            final mesesKeys = citasPorMes.keys.toList();
            final valores = citasPorMes.values.toList();

            return Column(
              children: [
                //
                // ────────────────────────────────────
                //   LINE CHART
                // ────────────────────────────────────
                //
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Citas por mes (Últimos 6 meses) – LineChart",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          height: 240,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  spots: [
                                    for (int i = 0; i < valores.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        valores[i].toDouble(),
                                      ),
                                  ],
                                  dotData: FlDotData(show: true),
                                  color: Colors.blue,
                                  barWidth: 3,
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final i = value.toInt();
                                      if (i < 0 || i >= mesesKeys.length) {
                                        return const Text("");
                                      }

                                      final parts = mesesKeys[i].split("/");
                                      final mesNum =
                                          int.tryParse(parts[0]) ?? 1;

                                      return Text(
                                        _mesesText[mesNum],
                                        style: const TextStyle(fontSize: 11),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //
                // ────────────────────────────────────
                //   BAR CHART
                // ────────────────────────────────────
                //
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Citas por mes – BarChart",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          height: 260,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: [
                                for (int i = 0; i < valores.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: valores[i].toDouble(),
                                        width: 18,
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final i = value.toInt();
                                      if (i < 0 || i >= mesesKeys.length) {
                                        return const Text("");
                                      }

                                      final parts = mesesKeys[i].split("/");
                                      final mesNum =
                                          int.tryParse(parts[0]) ?? 1;

                                      return Text(
                                        _mesesText[mesNum],
                                        style: const TextStyle(fontSize: 11),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
