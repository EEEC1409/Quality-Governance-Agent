import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import 'aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import 'aplicacion/casos_de_uso/verificar_primer_uso_uc.dart';
import 'adaptadores/presentadores/bienvenida_presenter.dart';
import 'infraestructura/inyeccion/inyeccion_dependencias.dart';
import 'infraestructura/ui/pantallas/arranque_screen.dart';
import 'infraestructura/ui/pantallas/bienvenida_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InyeccionDependencias.inicializar();
  runApp(const ResuelveApp());
}

class ResuelveApp extends StatelessWidget {
  const ResuelveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;
    return MaterialApp(
      title: 'Resuelve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C9A7)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => ArranqueScreen(
              verificarPrimerUsoUC: sl<VerificarPrimerUsoUC>(),
            ),
        '/bienvenida': (_) => BienvenidaScreen(
              presenter: BienvenidaPresenter(
                obtenerContenidoUC: sl<ObtenerContenidoBienvenidaUC>(),
                marcarVistaUC: sl<MarcarBienvenidaVistaUC>(),
              ),
              onContinuar: () {},
            ),
        '/cedula': (_) => const Scaffold(
              body: Center(child: Text('Pantalla de Cédula — por implementar')),
            ),
      },
    );
  }
}
