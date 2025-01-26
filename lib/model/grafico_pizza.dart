import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoPizza extends StatelessWidget {
  final double valorInvestido;
  final double valorJuros;

  const GraficoPizza({
    super.key,
    required this.valorInvestido,
    required this.valorJuros,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _criarSecoes(),
          centerSpaceRadius: 50, // Espaço no centro
          centerSpaceColor: Colors.white,
          sectionsSpace: 2, // Espaço entre as seções
          startDegreeOffset: 0,
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (event, response) {
              if (response == null || event.isInterestedForInteractions == false) {
                return;
              }
            },
          ),
        ),
        duration: const Duration(milliseconds: 250), // Animação de transição
        curve: Curves.easeInOut, // Curva de animação
      ),
    );
  }

  List<PieChartSectionData> _criarSecoes() {
    final total = valorInvestido + valorJuros;

    return [
      PieChartSectionData(
        value: valorInvestido,
        color: Colors.blue,
        radius: 60,
        title: 'Investido\n${((valorInvestido / total) * 100).toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        value: valorJuros,
        color: Colors.green,
        radius: 60,
        title: 'Juros\n${((valorJuros / total) * 100).toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 0.6,
      ),
    ];
  }
}
