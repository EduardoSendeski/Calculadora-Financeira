import 'dart:math';

class CalculationService {
  static String? validateFields(
      String? investment, String? monthlyContribution, String? rate, String? time) {
    if (investment == null || investment.isEmpty) {
      return "O campo 'Valor Inicial' está vazio.";
    }
    if (rate == null || rate.isEmpty) {
      return "O campo 'Taxa de Juros' está vazio.";
    }
    if (time == null || time.isEmpty) {
      return "O campo 'Tempo' está vazio.";
    }
    return null;
  }

  static double calculateCompoundInterest({
    required double principal,
    required double rate,
    required int time,
    required double monthlyContribution,
  }) {
    // Fórmula para converter taxa anual em taxa mensal
    // jm = [(1 + ja)^(1/12) – 1] x 100
    rate = (pow((1 + rate / 100), 1 / 12) - 1) * 100;

    // Fórmula de juros compostos com aportes mensais
    double total = principal * pow((1 + rate / 100), time); // Juros compostos sobre o valor inicial

    for (int i = 1; i <= time; i++) {
      // Juros compostos sobre os aportes mensais
      total += monthlyContribution * pow((1 + rate / 100), time - i);
    }

    return total;
  }
}
