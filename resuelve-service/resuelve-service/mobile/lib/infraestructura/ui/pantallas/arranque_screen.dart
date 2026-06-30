import 'package:flutter/material.dart';

import '../../../aplicacion/casos_de_uso/verificar_primer_uso_uc.dart';

class ArranqueScreen extends StatefulWidget {
  final VerificarPrimerUsoUC verificarPrimerUsoUC;

  const ArranqueScreen({super.key, required this.verificarPrimerUsoUC});

  @override
  State<ArranqueScreen> createState() => _ArranqueScreenState();
}

class _ArranqueScreenState extends State<ArranqueScreen> {
  @override
  void initState() {
    super.initState();
    _decidirPantalla();
  }

  Future<void> _decidirPantalla() async {
    final debeVerBienvenida = await widget.verificarPrimerUsoUC.ejecutar();
    if (!mounted) return;

    if (debeVerBienvenida) {
      Navigator.of(context).pushReplacementNamed('/bienvenida');
    } else {
      Navigator.of(context).pushReplacementNamed('/cedula');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
      ),
    );
  }
}
