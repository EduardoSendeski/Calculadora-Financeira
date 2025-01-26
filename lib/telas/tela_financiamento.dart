import 'package:flutter/material.dart';
import 'dart:math';

class TelaFinanciamento extends StatefulWidget {
  const TelaFinanciamento({super.key});

  @override
  State<TelaFinanciamento> createState() => _TelaFinanciamentoState();
}

class _TelaFinanciamentoState extends State<TelaFinanciamento> {
  final TextEditingController _numMesesController = TextEditingController();
  final TextEditingController _taxaJurosController = TextEditingController();
  final TextEditingController _valorPrestacaoController = TextEditingController();
  final TextEditingController _valorFinanciadoController = TextEditingController();

  String? _resultado;
  String? _campoCalculado;

  void _calcular() {
    final int? n = int.tryParse(_numMesesController.text);
    final double? j = double.tryParse(_taxaJurosController.text);
    final double? p = double.tryParse(_valorPrestacaoController.text);
    final double? q0 = double.tryParse(_valorFinanciadoController.text);

    try {
      if (n == null && p != null && j != null && j > 0 && q0 != null) {
        // Cálculo do nº de meses
        final resultado = log(p / (p - (j / 100) * q0)) / log(1 + (j / 100));
        _resultado = "Nº de Meses: ${resultado.ceil()}";
        _campoCalculado = "Nº de Meses";
      } else if (j == null && n != null && p != null && q0 != null) {
        // Cálculo da taxa de juros
        double taxa = 0.01;
        for (int i = 0; i < 10000; i++) {
          double teste = q0 * (taxa / (1 - pow(1 + taxa, -n)));
          if ((teste - p).abs() < 0.0001) break;
          taxa += 0.00001;
        }
        _resultado = "Taxa de Juros Mensal: ${(taxa * 100).toStringAsFixed(2)}%";
        _campoCalculado = "Taxa de Juros Mensal";
      } else if (p == null && n != null && j != null && j > 0 && q0 != null) {
        // Cálculo da prestação
        final resultado = q0 * ((j / 100) / (1 - pow(1 + (j / 100), -n)));
        _resultado = "Valor da Prestação: R\$ ${resultado.toStringAsFixed(2)}";
        _campoCalculado = "Valor da Prestação";
      } else if (q0 == null && n != null && j != null && j > 0 && p != null) {
        // Cálculo do valor financiado
        final resultado = (p * (1 - pow(1 + (j / 100), -n))) / (j / 100);
        _resultado = "Valor Financiado: R\$ ${resultado.toStringAsFixed(2)}";
        _campoCalculado = "Valor Financiado";
      } else {
        _resultado = "Preencha corretamente os campos para calcular.";
        _campoCalculado = null;
      }
    } catch (e) {
      _resultado = "Erro no cálculo: Verifique os valores informados.";
      _campoCalculado = null;
    }
    setState(() {});
  }

  void _limpar() {
    _numMesesController.clear();
    _taxaJurosController.clear();
    _valorPrestacaoController.clear();
    _valorFinanciadoController.clear();
    setState(() {
      _resultado = null;
      _campoCalculado = null;
    });
  }

  Widget _buildCampoTexto(String label, TextEditingController controller, String tooltip) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Tooltip(
          message: tooltip,
          child: const Icon(Icons.info_outline, color: Colors.green),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulador de Financiamento"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Deixe o campo que deseja calcular em branco:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildCampoTexto("Nº de Meses", _numMesesController, "Tempo total do financiamento em meses."),
            const SizedBox(height: 12),
            _buildCampoTexto("Taxa de Juros Mensal (%)", _taxaJurosController, "Taxa de juros cobrada por mês."),
            const SizedBox(height: 12),
            _buildCampoTexto("Valor da Prestação (R\$)", _valorPrestacaoController, "Valor fixo pago mensalmente."),
            const SizedBox(height: 12),
            _buildCampoTexto("Valor Financiado (R\$)", _valorFinanciadoController, "Valor total do empréstimo."),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text("Calcular", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _limpar,
              icon: const Icon(Icons.cleaning_services, color: Colors.white),
              label: const Text("Limpar", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            if (_resultado != null)
              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        "Resultado do Cálculo:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _resultado!,
                        style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      if (_campoCalculado != null)
                        Text(
                          "Campo Calculado: $_campoCalculado",
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
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
