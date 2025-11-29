import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphicsPage extends StatefulWidget {
  final String doctorId;

  const GraphicsPage({super.key, required this.doctorId});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  bool loading = true;
  Map<int, int> citasPorMes = {}; // mes

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Cargar datos reales desde Firebase
  Future<void> loadData() async {
    final q = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .get();

    final Map<int, int> meses = {};

    for (var doc in q.docs) {
      final data = doc.data();

      if (data['createdAt'] != null) {
        final date = (data['createdAt'] as Timestamp).toDate();
        final mes = date.month;

        meses[mes] = (meses[mes] ?? 0) + 1;
      }
    }

    // Ordenar por mes
    final sortedMonths = Map.fromEntries(
      meses.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Actualizar estado
    setState(() {
      citasPorMes = sortedMonths; // Funcionalidad para el orden
      loading = false;
    });
  }

  // Line Chart
  Widget lineChart() {
    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            spots: citasPorMes.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                .toList(),
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                _mesNombre(value.toInt()),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bar Chart
  Widget barChart() {
    return BarChart(
      BarChartData(
        barGroups: citasPorMes.entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: Colors.deepPurple,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                _mesNombre(value.toInt()),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _mesNombre(int m) {
    const meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return (m >= 1 && m <= 12) ? meses[m] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas del Doctor")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Gráfica LineChart
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Citas creadas por mes (LineChart)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 250, child: lineChart()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gráfica BarChart
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Citas creadas por mes (BarChart)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 250, child: barChart()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
