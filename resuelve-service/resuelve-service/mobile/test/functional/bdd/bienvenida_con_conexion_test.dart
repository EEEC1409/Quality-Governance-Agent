import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import 'package:resuelve_app/dominio/entidades/contenido_bienvenida.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/adaptadores/presentadores/bienvenida_presenter.dart';
import 'package:resuelve_app/infraestructura/ui/pantallas/bienvenida_screen.dart';

import 'bienvenida_con_conexion_test.mocks.dart';

@GenerateMocks([ObtenerContenidoBienvenidaUC, MarcarBienvenidaVistaUC])
void main() {
  late MockObtenerContenidoBienvenidaUC mockObtenerUC;
  late MockMarcarBienvenidaVistaUC mockMarcarUC;

  setUp(() {
    mockObtenerUC = MockObtenerContenidoBienvenidaUC();
    mockMarcarUC = MockMarcarBienvenidaVistaUC();
  });

  Widget crearApp() {
    final presenter = BienvenidaPresenter(
      obtenerContenidoUC: mockObtenerUC,
      marcarVistaUC: mockMarcarUC,
    );
    return MaterialApp(home: BienvenidaScreen(presenter: presenter));
  }

  group('BienvenidaScreen — primer acceso con conexión', () {
    testWidgets(
        'Dado que la APP arranca con conexión, '
        'Cuando la pantalla de bienvenida carga, '
        'Entonces el logo de Resuelve es visible', (tester) async {
      when(mockObtenerUC.ejecutar()).thenAnswer((_) async => const Success(
            ContenidoBienvenida(
              logoUrl: 'https://assets.resuelve.com/logo.png',
              videoUrl: 'https://assets.resuelve.com/video.mp4',
              version: '2.1.0',
            ),
          ));

      await tester.pumpWidget(crearApp());
      await tester.pump();

      expect(find.byKey(const Key('logo_bienvenida')), findsOneWidget);
    });

    testWidgets(
        'Dado que el contenido carga exitosamente, '
        'Cuando la pantalla se muestra, '
        'Entonces el botón Continuar está siempre visible', (tester) async {
      when(mockObtenerUC.ejecutar()).thenAnswer((_) async => const Success(
            ContenidoBienvenida(
              logoUrl: 'https://assets.resuelve.com/logo.png',
              videoUrl: 'https://assets.resuelve.com/video.mp4',
              version: '2.1.0',
            ),
          ));

      await tester.pumpWidget(crearApp());
      await tester.pump();

      expect(find.byKey(const Key('boton_continuar')), findsOneWidget);
    });

    testWidgets(
        'Dado que la pantalla está activa, '
        'Cuando el usuario toca el botón Continuar, '
        'Entonces la APP marca la bienvenida como vista', (tester) async {
      when(mockObtenerUC.ejecutar()).thenAnswer((_) async => const Success(
            ContenidoBienvenida(
              logoUrl: 'https://assets.resuelve.com/logo.png',
              videoUrl: 'https://assets.resuelve.com/video.mp4',
              version: '2.1.0',
            ),
          ));
      when(mockMarcarUC.ejecutar()).thenAnswer((_) async {});

      await tester.pumpWidget(crearApp());
      await tester.pump();
      await tester.tap(find.byKey(const Key('boton_continuar')));
      await tester.pump();

      verify(mockMarcarUC.ejecutar()).called(1);
    });
  });
}
