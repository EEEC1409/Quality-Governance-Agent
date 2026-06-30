import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/adaptadores/gateways/contenido_marca_gateway.dart';
import 'package:resuelve_app/adaptadores/presentadores/bienvenida_presenter.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import 'package:resuelve_app/dominio/entidades/excepciones.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/infraestructura/red/generated/api/marca_api.dart';
import 'package:resuelve_app/infraestructura/ui/pantallas/bienvenida_screen.dart';

import 'contenido_marca_gateway_cdn_error_test.mocks.dart';

@GenerateMocks([MarcaApi, ObtenerContenidoBienvenidaUC, MarcarBienvenidaVistaUC])
void main() {
  group('ContenidoMarcaGateway — error CDN 404/500 (Remediación H2)', () {
    setUp(() {
      ConnectivityPlatform.instance =
          _MockConnectivityPlatform([ConnectivityResult.wifi]);
    });

    for (final statusCode in [404, 500]) {
      test(
          'Dado que el servidor responde HTTP $statusCode, '
          'Cuando se llama obtener(), '
          'Entonces retorna Failure(ErrorCdnException($statusCode))', () async {
        final mockApi = MockMarcaApi();
        when(mockApi.obtenerContenidoBienvenida()).thenAnswer(
          (_) async => throw DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: statusCode,
              requestOptions: RequestOptions(path: '/v1/marca/contenido-bienvenida'),
            ),
            requestOptions: RequestOptions(path: '/v1/marca/contenido-bienvenida'),
          ),
        );

        final gateway = ContenidoMarcaGateway(mockApi);
        final resultado = await gateway.obtener();

        expect(resultado, isA<Failure>());
        final failure = resultado as Failure;
        expect(failure.error, isA<ErrorCdnException>());
        expect((failure.error as ErrorCdnException).statusCode, statusCode);
      });
    }

    testWidgets(
        'Dado que el CDN responde 404/500, '
        'Cuando el BienvenidaPresenter procesa el resultado, '
        'Entonces emite estado sinVideo sin mostrar mensaje de error al usuario',
        (tester) async {
      final mockObtenerUC = MockObtenerContenidoBienvenidaUC();
      final mockMarcarUC = MockMarcarBienvenidaVistaUC();

      when(mockObtenerUC.ejecutar())
          .thenAnswer((_) async => Failure(const ErrorCdnException(404)));

      final presenter = BienvenidaPresenter(
        obtenerContenidoUC: mockObtenerUC,
        marcarVistaUC: mockMarcarUC,
      );

      await tester.pumpWidget(
        MaterialApp(home: BienvenidaScreen(presenter: presenter)),
      );
      await tester.pump();

      expect(presenter.estado, isA<BienvenidaSinVideo>());
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

class _MockConnectivityPlatform extends ConnectivityPlatform {
  final List<ConnectivityResult> _results;
  _MockConnectivityPlatform(this._results);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(_results);
}
