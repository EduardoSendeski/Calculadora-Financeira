import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiMoedas {
  final String baseUrl =
      'https://economia.awesomeapi.com.br/json/last/USD-BRL,BTC-BRL';

  /// Busca as cotações do Dólar e Bitcoin
  Future<Map<String, dynamic>> fetchCotacoes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return {
          "dolar": jsonData['USDBRL']['bid'], // Valor atual do dólar
          "btc": jsonData['BTCBRL']['bid'], // Valor atual do Bitcoin
        };
      } else {
        throw Exception('Erro ao buscar as cotações.');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
