import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoColuna extends StatelessWidget {
  final List<double> valoresInvestidos;
  final List<double> valoresJuros;

  const GraficoColuna({
    super.key,
    required this.valoresInvestidos,
    required this.valoresJuros,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                valoresInvestidos.length,
                (index) => BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: valoresInvestidos[index] + valoresJuros[index],
                      rodStackItems: [
                        BarChartRodStackItem(
                          0,
                          valoresInvestidos[index],
                          Colors.blue, // Cor para o valor investido
                        ),
                        BarChartRodStackItem(
                          valoresInvestidos[index],
                          valoresInvestidos[index] + valoresJuros[index],
                          Colors.green, // Cor para o valor dos juros
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              maxY: (valoresInvestidos.reduce((a, b) => a > b ? a : b) +
                      valoresJuros.reduce((a, b) => a > b ? a : b)) *
                  1.2, // Garante espaço no topo
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Remove os números do eixo Y
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Remove possíveis números no eixo direito
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Remove possíveis números no topo
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Remove os números do eixo X
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              gridData: const FlGridData(show: false), // Remove as grades
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  tooltipRoundedRadius: 8,
                  tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      'Investido: R\$ ${valoresInvestidos[groupIndex].toStringAsFixed(2)}\n'
                      'Juros: R\$ ${valoresJuros[groupIndex].toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 250), // Animação ao estado final
            curve: Curves.easeInOut, // Curva de animação
          ),
        ),
        const SizedBox(height: 16),
        _buildLegenda(),
      ],
    );
  }

  Widget _buildLegenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendaItem('Valor Investido', Colors.blue),
        const SizedBox(width: 16),
        _buildLegendaItem('Valor do Juro', Colors.green),
      ],
    );
  }

  Widget _buildLegendaItem(String titulo, Color cor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: cor,
        ),
        const SizedBox(width: 8),
        Text(titulo, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
