import 'dart:math';

class CalculoService {
  static String calcularInvestimento({
    required double valorInicial,
    required double aporteMensal,
    required double taxa,
    required int periodo,
    required String unidadePeriodo,
    required String tipoTaxa,
    required bool ignorarTributacao,
    required bool selecionarRendaFixa,
  }) {
    if (unidadePeriodo == 'Anos') periodo *= 12;

    double taxaMensal = tipoTaxa == 'Anual' ? (pow(1 + taxa / 100, 1 / 12) - 1) * 100 : taxa;

    double total = valorInicial * pow(1 + taxaMensal / 100, periodo);
    for (int i = 1; i <= periodo; i++) {
      total += aporteMensal * pow(1 + taxaMensal / 100, periodo - i);
    }

    return "Total Acumulado: R\$ ${total.toStringAsFixed(2)}";
  }
}
