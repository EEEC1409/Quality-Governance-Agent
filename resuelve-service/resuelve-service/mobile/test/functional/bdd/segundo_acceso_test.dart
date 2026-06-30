import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/verificar_primer_uso_uc.dart';
import 'package:resuelve_app/infraestructura/ui/pantallas/arranque_screen.dart';

import 'segundo_acceso_test.mocks.dart';

@GenerateMocks([VerificarPrimerUsoUC])
void main() {
  group('ArranqueScreen — segundo acceso (bienvenida ya vista)', () {
    testWidgets(
        'Dado que el flag primer_uso_completado es true, '
        'Cuando la APP arranca, '
        'Entonces la APP omite la pantalla de bienvenida '
        'y navega directamente al flujo de autenticación', (tester) async {
      final mockVerificarUC = MockVerificarPrimerUsoUC();
      when(mockVerificarUC.ejecutar()).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        home: ArranqueScreen(verificarPrimerUsoUC: mockVerificarUC),
        routes: {
          '/cedula': (_) => const Scaffold(
                body: Center(
                  child: Text('Pantalla Cédula', key: Key('pantalla_cedula')),
                ),
              ),
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pantalla_cedula')), findsOneWidget);
    });

    testWidgets(
        'Dado que el flag primer_uso_completado es false, '
        'Cuando la APP arranca, '
        'Entonces la APP muestra la pantalla de bienvenida', (tester) async {
      final mockVerificarUC = MockVerificarPrimerUsoUC();
      when(mockVerificarUC.ejecutar()).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        home: ArranqueScreen(verificarPrimerUsoUC: mockVerificarUC),
        routes: {
          '/bienvenida': (_) => const Scaffold(
                body: Center(
                  child: Text('Pantalla Bienvenida',
                      key: Key('pantalla_bienvenida')),
                ),
              ),
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pantalla_bienvenida')), findsOneWidget);
    });
  });
}
