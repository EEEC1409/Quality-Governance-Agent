import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/adaptadores/gateways/contenido_marca_gateway.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/infraestructura/red/generated/api/marca_api.dart';

import 'contenido_marca_gateway_timeout_test.mocks.dart';

@GenerateMocks([MarcaApi])
void main() {
  group('ContenidoMarcaGateway — timeout de red (Remediación H2)', () {
    setUp(() {
      ConnectivityPlatform.instance =
          _MockConnectivityPlatform([ConnectivityResult.wifi]);
    });

    testWidgets(
        'Dado que la petición HTTP excede el timeout (red interrumpida mid-stream), '
        'Cuando se llama obtener(), '
        'Entonces retorna Failure(TimeoutException) sin propagar excepción no controlada',
        (tester) async {
      final mockApi = MockMarcaApi();
      when(mockApi.obtenerContenidoBienvenida()).thenAnswer(
        (_) async => throw DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/v1/marca/contenido-bienvenida'),
        ),
      );

      final gateway = ContenidoMarcaGateway(mockApi);
      final resultado = await gateway.obtener();

      expect(resultado, isA<Failure>());
      final failure = resultado as Failure;
      expect(failure.error, isA<TimeoutException>());
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
