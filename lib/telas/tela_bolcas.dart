import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_cotacao.dart';

class TelaBolcas extends StatefulWidget {
  const TelaBolcas({super.key});

  @override
  _TelaBolcasState createState() => _TelaBolcasState();
}

class _TelaBolcasState extends State<TelaBolcas> {
  final QuoteApi quoteApi = QuoteApi();
  List<String> availableTickers = [];
  bool isLoadingTickers = true;
  List<Map<String, dynamic>> cards = [];
  List<String> savedTickers = [];

  final List<String> topBrazilianTickers = [
    "^BVSP", "PETR4", "VALE3", "ITUB4", "BBDC4",
    "ABEV3", "MGLU3", "B3SA3", "GGBR4", "ELET3",
    "LREN3", "RAIL3", "JBSS3", "PRIO3", "EQTL3",
    "WEGE3", "SUZB3", "CSAN3", "BRFS3", "BBAS3"
  ];

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<void> _initializeCards() async {
    await _loadSavedTickers();
    for (String ticker in savedTickers) {
      await _adicionarCard(ticker);
    }
    setState(() {
      availableTickers = topBrazilianTickers;
      isLoadingTickers = false;
    });
  }

  Future<void> _loadSavedTickers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTickers = prefs.getStringList("savedTickers") ?? [];
    });
    print("Saved Tickers: $savedTickers");
  }

  Future<void> _saveTickers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("savedTickers", savedTickers);
  }

  Future<void> _adicionarCard(String ticker) async {
    if (!savedTickers.contains(ticker)) {
      savedTickers.add(ticker);
      await _saveTickers();
    }

    try {
      final data = await quoteApi.getQuote(ticker);
      setState(() {
        cards.add({"ticker": ticker, "data": data});
      });
    } catch (e) {
      print("Erro ao adicionar card: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar dados para $ticker")),
      );
    }
  }

  Future<void> _removerCard(String ticker) async {
    setState(() {
      cards.removeWhere((card) => card['ticker'] == ticker);
      savedTickers.remove(ticker);
    });
    await _saveTickers();
  }

  void _exibirMenuFlutuante(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (isLoadingTickers) {
          return const Center(child: CircularProgressIndicator());
        } else if (availableTickers.isEmpty) {
          return const Center(child: Text("Nenhum ticker disponível."));
        } else {
          return ListView.builder(
            itemCount: availableTickers.length,
            itemBuilder: (context, index) {
              final ticker = availableTickers[index];
              return ListTile(
                title: Text(ticker),
                onTap: () {
                  Navigator.pop(context);
                  _adicionarCard(ticker);
                },
              );
            },
          );
        }
      },
    );
  }

  String formatarPreco(dynamic valor) {
    if (valor == null) return "0,00";
    return "R\$ ${valor.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cotações da Bolsa"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _exibirMenuFlutuante(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final data = card['data'];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        card['ticker'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Última atualização: ${data['regularMarketTime'] ?? 'N/A'}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatarPreco(data['price']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerCard(card['ticker']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}