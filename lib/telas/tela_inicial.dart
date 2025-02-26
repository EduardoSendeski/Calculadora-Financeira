import 'package:flutter/material.dart';
import '../api/api_cotacao.dart';
import '../api/api_moedas.dart';
import '../widgets/cotacao_card.dart';
import '../widgets/custom_button.dart';
import '../model/formulario_calculo.dart';
import '../telas/tela_dados.dart';
import 'tela_sobre.dart';
import 'tela_financiamento.dart';
import 'tela_bolcas.dart';
import 'login.dart';
import 'profile_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final ApiMoedas apiMoedas = ApiMoedas();
  final QuoteApi quoteApi = QuoteApi();

  String? cotacaoDolar;
  String? cotacaoBTC;
  String? cotacaoIBOV;

@override
void initState() {
  super.initState();
  _fetchCotacoes();
  _loadUserData();
}

  Future<void> _loadUserData() async {
  await Future.delayed(const Duration(milliseconds: 500)); // Pequeno delay para garantir que o usuário já foi carregado
  setState(() {}); // Força a atualização da tela para carregar os ícones corretamente
}
  Future<void> _fetchCotacoes() async {
    try {
      // Busca cotações do dólar e bitcoin
      final data = await apiMoedas.fetchCotacoes();
      if (mounted) {
        setState(() {
          cotacaoDolar = data['dolar'] ?? "Indisponível";
          cotacaoBTC = data['btc'] ?? "Indisponível";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cotacaoDolar = "Erro";
          cotacaoBTC = "Erro";
        });
      }
    }

    // Busca a cotação fixa do IBOVESPA
    try {
      const ibovTicker = '^BVSP'; // Certifique-se de usar o ticker correto
      final ibovData = await quoteApi.getQuote(ibovTicker);

      print("Dados recebidos do IBOVESPA: $ibovData"); // DEBUG: Log para verificar a resposta

      // Usa o campo 'price' da API
      final cotacao = ibovData['price']?.toString() ?? "Indisponível";

      if (mounted) {
        setState(() {
          cotacaoIBOV = cotacao;
        });
      }
    } catch (e) {
      print("Erro ao buscar IBOVESPA: $e"); // DEBUG: Log de erro
      if (mounted) {
        setState(() {
          cotacaoIBOV = "Erro ao buscar IBOV";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCotacoes(),
                    const SizedBox(height: 20),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildHeader(BuildContext context) {
  final user = Supabase.instance.client.auth.currentUser;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "Simulador Financeiro",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Se o usuário ainda não foi carregado, exibir um indicador de carregamento
        if (user == null)
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: Colors.white),
          )
        else
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
                  );

                  if (result == true) {
                    setState(() {}); // Recarrega a tela para atualizar os dados
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ],
          ),
      ],
    ),
  );
}



  Widget _buildCotacoes() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CotacaoCard(
                moeda: "Dólar Americano",
                valor: cotacaoDolar,
                icone: Icons.attach_money,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CotacaoCard(
                moeda: "Bitcoin",
                valor: cotacaoBTC,
                icone: Icons.currency_bitcoin,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CotacaoCard(
          moeda: "Ibovespa (IBOV)",
          valor: cotacaoIBOV,
          icone: Icons.show_chart,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          CustomButton(
            label: "Investimentos",
            icon: Icons.show_chart,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormularioCalculo()),
              );
            },
          ),
          CustomButton(
            label: "Taxa Selic",
            icon: Icons.bar_chart,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaDados()),
              );
            },
          ),
          CustomButton(
            label: "Sobre",
            icon: Icons.info_outline,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaSobre()),
              );
            },
          ),
          CustomButton(
            label: "Financiamento",
            icon: Icons.calculate_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaFinanciamento()),
              );
            },
          ),
          CustomButton(
            label: "Bolças",
            icon: Icons.trending_up,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaBolcas()),
              );
            },
          ),
        ],
      ),
    );
  }
}
