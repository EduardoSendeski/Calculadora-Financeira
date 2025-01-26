import 'package:flutter/material.dart';
import '../api/api_selic_bc.dart';
import '../widgets/widgets.dart';

class TelaDados extends StatefulWidget {
  const TelaDados({super.key});

  @override
  _TelaDadosState createState() => _TelaDadosState();
}

class _TelaDadosState extends State<TelaDados> {
  final ApiSelicBC apiSelicBC = ApiSelicBC();
  final TextEditingController _anosController = TextEditingController();

  double? selicAtual;
  String? dataSelicAtual;
  Map<int, double>? mediasAnuais;
  double? mediaPeriodo;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSelicAtual();
  }

  Future<void> _fetchSelicAtual() async {
    try {
      final data = await apiSelicBC.fetchSelic();
      setState(() {
        selicAtual = data['selicAtual'];
        dataSelicAtual = data['dataSelicAtual'];
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao buscar a Taxa Selic Atual.";
      });
    }
  }

  Future<void> _calcularMedia() async {
    if (_anosController.text.isEmpty) {
      setState(() {
        errorMessage = "Informe o número de anos.";
      });
      return;
    }

    try {
      int anos = int.parse(_anosController.text);
      String dataInicial = "01/01/${DateTime.now().year - anos}";
      String dataFinal = "31/12/${DateTime.now().year}";

      final data =
          await apiSelicBC.fetchSelic(dataInicial: dataInicial, dataFinal: dataFinal);

      setState(() {
        mediasAnuais = data['mediasAnuais'];
        mediaPeriodo = data['mediaPeriodo'];
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao calcular a média.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Informações Financeiras"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: errorMessage != null
          ? ErrorMessageWidget(message: errorMessage!, onRetry: _fetchSelicAtual)
          : selicAtual == null
              ? const Center(child: CircularProgressIndicator())
              : DataDisplayWidget(
                  selicAtual: selicAtual!,
                  dataSelicAtual: dataSelicAtual!,
                  mediasAnuais: mediasAnuais,
                  mediaPeriodo: mediaPeriodo,
                  anosController: _anosController,
                  onCalculate: _calcularMedia,
                ),
    );
  }
}
