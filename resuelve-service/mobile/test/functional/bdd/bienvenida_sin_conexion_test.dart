import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import 'package:resuelve_app/dominio/entidades/excepciones.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/adaptadores/presentadores/bienvenida_presenter.dart';
import 'package:resuelve_app/infraestructura/ui/pantallas/bienvenida_screen.dart';

import 'bienvenida_con_conexion_test.mocks.dart';

void main() {
  late MockObtenerContenidoBienvenidaUC mockObtenerUC;
  late MockMarcarBienvenidaVistaUC mockMarcarUC;

  setUp(() {
    mockObtenerUC = MockObtenerContenidoBienvenidaUC();
    mockMarcarUC = MockMarcarBienvenidaVistaUC();
    when(mockObtenerUC.ejecutar())
        .thenAnswer((_) async => Failure(const SinConectividadException()));
  });

  Widget crearApp() {
    final presenter = BienvenidaPresenter(
      obtenerContenidoUC: mockObtenerUC,
      marcarVistaUC: mockMarcarUC,
    );
    return MaterialApp(home: BienvenidaScreen(presenter: presenter));
  }

  group('BienvenidaScreen — primer acceso sin conexión', () {
    testWidgets(
        'Dado que el dispositivo no tiene conexión, '
        'Cuando la pantalla de bienvenida carga, '
        'Entonces el logo de Resuelve se muestra siempre', (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pump();

      expect(find.byKey(const Key('logo_bienvenida')), findsOneWidget);
    });

    testWidgets(
        'Dado que el dispositivo no tiene conexión, '
        'Cuando la pantalla carga, '
        'Entonces no se muestra ningún mensaje de error al usuario', (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('error'), findsNothing);
      expect(find.text('Error'), findsNothing);
    });

    testWidgets(
        'Dado que el dispositivo no tiene conexión, '
        'Cuando la pantalla carga, '
        'Entonces el botón Continuar está habilitado y visible', (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pump();

      expect(find.byKey(const Key('boton_continuar')), findsOneWidget);
      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key('boton_continuar')),
      );
      expect(boton.onPressed, isNotNull);
    });

    testWidgets(
        'Dado que el dispositivo no tiene conexión y el usuario toca Continuar, '
        'Cuando ocurre el evento de toque, '
        'Entonces la APP marca la bienvenida como vista', (tester) async {
      when(mockMarcarUC.ejecutar()).thenAnswer((_) async {});

      await tester.pumpWidget(crearApp());
      await tester.pump();
      await tester.tap(find.byKey(const Key('boton_continuar')));
      await tester.pump();

      verify(mockMarcarUC.ejecutar()).called(1);
    });
  });
}
