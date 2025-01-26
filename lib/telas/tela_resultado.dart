import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/grafico_pizza.dart';
import '../model/grafico_coluna.dart';

class TelaResultado extends StatelessWidget {
  const TelaResultado({super.key});

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final double valorInicial = argumentos['valorInicial'];
    final double aporteMensal = argumentos['aporteMensal'];
    final double taxaMensal = argumentos['taxa'];
    final int periodo = argumentos['periodo'];
    final String unidadePeriodo = argumentos['unidadePeriodo'] ?? 'Meses';
    final double total = argumentos['total'];
    final double totalInvestido = argumentos['totalInvestido'];
    final double totalJuros = argumentos['totalJuros'];
    final double? aliquota = argumentos['aliquota'];
    final double impostoRenda = argumentos['impostoRenda'];
    final double valorLiquido = total - impostoRenda;

    // Formatação para moeda brasileira
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Gerar os valores para o gráfico
    final List<double> valoresInvestidos = [];
    final List<double> valoresJuros = [];
    double saldoAtual = valorInicial;

    for (int i = 0; i < periodo; i++) {
      // Aplica juros ao saldo atual
      saldoAtual *= (1 + taxaMensal / 100);

      // Adiciona o aporte mensal (exceto no primeiro mês)
      if (i > 0) saldoAtual += aporteMensal;

      // Calcula o valor investido e o rendimento acumulado
      double investidoAteAqui = valorInicial + (aporteMensal * i);
      double jurosAteAqui = saldoAtual - investidoAteAqui;

      valoresInvestidos.add(investidoAteAqui);
      valoresJuros.add(jurosAteAqui);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado do Cálculo'),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meu cálculo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _construirLinhaResultado('Valor Inicial', formatador.format(valorInicial)),
            _construirLinhaResultado('Aporte Mensal', formatador.format(aporteMensal)),
            _construirLinhaResultado('Taxa de Juros', '${taxaMensal.toStringAsFixed(2)}% (Mensal)'),
            _construirLinhaResultado('Período em', '$periodo $unidadePeriodo'),
            const SizedBox(height: 16),
            const Text(
              'Resultado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _construirLinhaResultado('Valor Total Final', formatador.format(total)),
            _construirLinhaResultado('Valor Total Investido', formatador.format(totalInvestido)),
            _construirLinhaResultado('Total em Juros', formatador.format(totalJuros)),
            if (aliquota != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Tributação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _construirLinhaResultado('Imposto Previsto', '${aliquota.toStringAsFixed(1)}% do rendimento'),
              _construirLinhaResultado('Valor Previsto de IR', formatador.format(impostoRenda)),
              _construirLinhaResultado('Valor Líquido Previsto', formatador.format(valorLiquido)),
            ],
            const SizedBox(height: 32),
            const Text(
              'Gráfico de Pizza',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GraficoPizza(
              valorInvestido: totalInvestido,
              valorJuros: totalJuros,
            ),
            const SizedBox(height: 32),
            const Text(
              'Gráfico de Colunas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GraficoColuna(
              valoresInvestidos: valoresInvestidos,
              valoresJuros: valoresJuros,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Desenvolvido por: Luiz Sendeski',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLinhaResultado(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: const TextStyle(fontSize: 16)),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
