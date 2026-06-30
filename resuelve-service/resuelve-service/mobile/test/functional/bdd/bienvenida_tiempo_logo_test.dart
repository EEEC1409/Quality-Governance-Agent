import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import 'package:resuelve_app/dominio/entidades/contenido_bienvenida.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/adaptadores/presentadores/bienvenida_presenter.dart';
import 'package:resuelve_app/infraestructura/ui/pantallas/bienvenida_screen.dart';

import 'bienvenida_con_conexion_test.mocks.dart';

void main() {
  group('CE-003 — Logo visible en < 2000 ms (Remediación C2)', () {
    testWidgets(
        'Dado que la APP arranca, '
        'Cuando la pantalla de bienvenida carga, '
        'Entonces el logo es visible en menos de 2000 ms', (tester) async {
      final mockObtenerUC = MockObtenerContenidoBienvenidaUC();
      final mockMarcarUC = MockMarcarBienvenidaVistaUC();

      when(mockObtenerUC.ejecutar()).thenAnswer((_) async => const Success(
            ContenidoBienvenida(
              logoUrl: 'https://assets.resuelve.com/logo.png',
              videoUrl: 'https://assets.resuelve.com/video.mp4',
              version: '2.1.0',
            ),
          ));

      final presenter = BienvenidaPresenter(
        obtenerContenidoUC: mockObtenerUC,
        marcarVistaUC: mockMarcarUC,
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(home: BienvenidaScreen(presenter: presenter)),
      );
      await tester.pump();

      final logoFinder = find.byKey(const Key('logo_bienvenida'));
      expect(logoFinder, findsOneWidget,
          reason: 'El logo debe ser visible inmediatamente al renderizar');

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'CE-003: el logo debe ser visible en < 2000 ms desde el arranque',
      );
    });
  });
}
