import 'package:flutter/material.dart';
import 'dart:math';

class FormularioCalculo extends StatefulWidget {
  const FormularioCalculo({super.key});

  @override
  State<FormularioCalculo> createState() => _FormularioCalculoState();
}

class _FormularioCalculoState extends State<FormularioCalculo> {
  final TextEditingController _valorInicialController = TextEditingController();
  final TextEditingController _aporteMensalController = TextEditingController();
  final TextEditingController _taxaController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();

  String _tipoTaxaSelecionada = 'Anual';
  String _unidadePeriodoSelecionada = 'Meses';

  bool _ignorarTributacao = true;
  bool _selecionarIOF = false;
  bool _selecionarRendaFixa = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulador de Investimentos"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            // Organiza a altura dos elementos
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _criarCampoTexto(
                    'Valor Inicial (R\$)', _valorInicialController),
                const SizedBox(height: 16.0),
                _criarCampoTexto('Aporte Mensal (R\$)', _aporteMensalController,
                    ehOpcional: true),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _criarCampoTexto(
                          'Taxa de Juros (%)', _taxaController),
                    ),
                    const SizedBox(width: 16.0),
                    DropdownButton<String>(
                      value: _tipoTaxaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _tipoTaxaSelecionada = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 'Mensal', child: Text('Mensal')),
                        DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _criarCampoTexto('Período', _periodoController),
                    ),
                    const SizedBox(width: 16.0),
                    DropdownButton<String>(
                      value: _unidadePeriodoSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _unidadePeriodoSelecionada = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'Meses', child: Text('Meses')),
                        DropdownMenuItem(value: 'Anos', child: Text('Anos')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ignorar Tributação'),
                    Switch(
                      value: _ignorarTributacao,
                      onChanged: (value) {
                        setState(() {
                          _ignorarTributacao = value;
                          if (value) {
                            _selecionarIOF = false;
                            _selecionarRendaFixa = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (!_ignorarTributacao) ...[
                  _criarSwitch("Selecionar IOF", _selecionarIOF, (value) {
                    setState(() {
                      _selecionarIOF = value;
                    });
                  }),
                  _criarSwitch("Tabela Renda Fixa", _selecionarRendaFixa,
                      (value) {
                    setState(() {
                      _selecionarRendaFixa = value;
                    });
                  }),
                ],
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _calcularResultado(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 12.0),
                    ),
                    child: const Text('Calcular'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _criarSwitch(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _criarCampoTexto(String rotulo, TextEditingController controller,
      {bool ehOpcional = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: rotulo,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        suffixText: ehOpcional ? '(Opcional)' : null,
      ),
      keyboardType: TextInputType.number,
    );
  }

void _calcularResultado(BuildContext context) {
  // Verificar se os campos obrigatórios estão preenchidos
  if (_valorInicialController.text.isEmpty ||
      _taxaController.text.isEmpty ||
      _periodoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Preencha todos os campos obrigatórios: Valor Inicial, Taxa de Juros e Período.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Conversão dos valores
  double valorInicial = double.tryParse(_valorInicialController.text) ?? 0.0;
  double aporteMensal = double.tryParse(_aporteMensalController.text) ?? 0.0;
  double taxa = double.tryParse(_taxaController.text) ?? 0.0;
  int periodo = int.tryParse(_periodoController.text) ?? 0;

  if (_unidadePeriodoSelecionada == 'Anos') {
    periodo *= 12;
  }

  // Taxa mensal
  double taxaMensal = _tipoTaxaSelecionada == 'Anual'
      ? (pow((1 + taxa / 100), 1 / 12) - 1) * 100
      : taxa;

  // Cálculo do valor total e total investido
  double totalInvestido = valorInicial + (aporteMensal * periodo);
  double total = valorInicial * pow((1 + taxaMensal / 100), periodo);

  for (int i = 1; i <= periodo; i++) {
    total += aporteMensal * pow((1 + taxaMensal / 100), periodo - i);
  }

  double totalJuros = total - totalInvestido;

  // Cálculo do imposto de renda
  double impostoRenda = 0.0;
  double aliquota = 0.0;

  if (!_ignorarTributacao && _selecionarRendaFixa) {
    aliquota = _calcularAliquota(periodo, _unidadePeriodoSelecionada);
    impostoRenda = totalJuros * (aliquota / 100);
  }

  // Debug para verificar valores
  print('Ignorar Tributação: $_ignorarTributacao');
  print('Selecionar Renda Fixa: $_selecionarRendaFixa');
  print('Aliquota: $aliquota');
  print('Imposto de Renda: $impostoRenda');

  // Navegar para a tela de resultado
  Navigator.pushNamed(context, '/resultado', arguments: {
    'valorInicial': valorInicial,
    'aporteMensal': aporteMensal,
    'taxa': taxaMensal,
    'periodo': periodo,
    'total': total,
    'totalInvestido': totalInvestido,
    'totalJuros': totalJuros,
    'impostoRenda': impostoRenda,
    'aliquota': aliquota,
  });
}


  double _calcularAliquota(int periodo, String unidadePeriodo) {
    int dias = unidadePeriodo == 'Meses' ? periodo * 30 : periodo * 365;
    if (dias <= 180) return 22.5;
    if (dias <= 360) return 20.0;
    if (dias <= 720) return 17.5;
    return 15.0;
  }
}
