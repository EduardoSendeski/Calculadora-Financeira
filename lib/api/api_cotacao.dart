import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteApi {
  final String baseUrl = 'https://b3api.me/api/quote';

  /// Retorna a lista de tickers disponíveis
  Future<List<String>> getAvailableTickers() async {
    final uri = Uri.parse('$baseUrl/available');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data); // Retorna a lista de tickers
      } else {
        throw Exception('Erro ao buscar tickers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  /// Retorna os dados de uma ação específica
Future<Map<String, dynamic>> getQuote(String ticker) async {
  final uri = Uri.parse('$baseUrl/$ticker');

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print("Resposta da API para $ticker: $data"); // DEBUG: Mostrar retorno
      return data;
    } else {
      throw Exception('Erro ao buscar cotação: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro de conexão: $e');
  }
}
}
