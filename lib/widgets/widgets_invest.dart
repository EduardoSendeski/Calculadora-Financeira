import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool ehOpcional;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.ehOpcional = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixText: ehOpcional ? "(Opcional)" : null,
      ),
      keyboardType: TextInputType.number,
    );
  }
}

class SwitchWidget extends StatelessWidget {
  final String titulo;
  final bool valor;
  final Function(bool) onChanged;

  const SwitchWidget({
    super.key,
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo),
        Switch(value: valor, onChanged: onChanged),
      ],
    );
  }
}
