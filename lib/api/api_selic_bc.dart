import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiSelicBC {
  final String baseUrl =
      "https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?formato=json";

  /// Busca a Selic Atual e calcula médias anuais e do período
  Future<Map<String, dynamic>> fetchSelic({
    String? dataInicial, // Formato: dd/MM/yyyy
    String? dataFinal,   // Formato: dd/MM/yyyy
  }) async {
    try {
      String url = baseUrl;

      if (dataInicial != null && dataFinal != null) {
        url += "&dataInicial=$dataInicial&dataFinal=$dataFinal";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.isEmpty) throw Exception("Nenhum dado encontrado.");

        // Taxa Selic Atual (último registro)
        var ultimoRegistro = jsonData.last;
        String dataSelicAtual = ultimoRegistro['data'];
        double selicAtual =
            double.parse(ultimoRegistro['valor'].replaceAll(',', '.'));

        // Agrupar valores por ano
        Map<int, List<double>> valoresPorAno = {};
        for (var item in jsonData) {
          String data = item['data'];
          double valor =
              double.tryParse(item['valor'].replaceAll(',', '.')) ?? 0.0;

          int ano = int.parse(data.split('/')[2]);
          valoresPorAno.putIfAbsent(ano, () => []);
          valoresPorAno[ano]!.add(valor);
        }

        // Calcular médias anuais
        Map<int, double> mediasAnuais = {};
        valoresPorAno.forEach((ano, valores) {
          mediasAnuais[ano] =
              valores.reduce((a, b) => a + b) / valores.length;
        });

        // Média do período solicitado
        double mediaPeriodo = mediasAnuais.values.reduce((a, b) => a + b) /
            mediasAnuais.length;

        return {
          "selicAtual": selicAtual,
          "dataSelicAtual": dataSelicAtual,
          "mediasAnuais": mediasAnuais,
          "mediaPeriodo": mediaPeriodo,
        };
      } else {
        throw Exception('Erro ao buscar os dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
