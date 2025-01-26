import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiSoja {
  final String cliente = "empresaxyz";
  final String hash = "1234567890";

  Future<List<String>> getEstados() async {
    final url = "https://api.agrolink.com.br/clientes/$cliente/$hash/Tabelas/GetEstados";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body).map((e) => e['Sigla']));
    } else {
      throw Exception("Erro ao buscar estados");
    }
  }

  Future<List<Map<String, dynamic>>> getCidades(String uf) async {
    final url = "https://api.agrolink.com.br/clientes/$cliente/$hash/Tabelas/GetCidades?uf=$uf&possuiCotacoes=true";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body)['cidades']);
    } else {
      throw Exception("Erro ao buscar cidades");
    }
  }

  Future<double?> getCotacaoSoja(String uf, String cidade) async {
    final url =
        "https://api.agrolink.com.br/clientes/$cliente/$hash/Cotacoes/CotacoesFechamentoLista?uf=$uf&cidade=$cidade&cod_especie=5&cod_produto=3";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.isNotEmpty ? data[0]['Valor'] : null;
    } else {
      throw Exception("Erro ao buscar cotação de soja");
    }
  }
}
