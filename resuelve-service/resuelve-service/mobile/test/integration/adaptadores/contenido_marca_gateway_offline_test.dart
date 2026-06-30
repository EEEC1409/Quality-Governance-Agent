import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/adaptadores/gateways/contenido_marca_gateway.dart';
import 'package:resuelve_app/dominio/entidades/excepciones.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/infraestructura/red/generated/api/marca_api.dart';
import 'package:dio/dio.dart';

import 'contenido_marca_gateway_offline_test.mocks.dart';

@GenerateMocks([MarcaApi])
void main() {
  group('ContenidoMarcaGateway — sin conectividad (Remediación H2)', () {
    testWidgets(
        'Dado que connectivity_plus reporta ConnectivityResult.none, '
        'Cuando se llama obtener(), '
        'Entonces retorna Failure(SinConectividadException) sin realizar llamada HTTP',
        (tester) async {
      final mockApi = MockMarcaApi();

      ConnectivityPlatform.instance = _MockConnectivityPlatform([ConnectivityResult.none]);

      final gateway = ContenidoMarcaGateway(mockApi);
      final resultado = await gateway.obtener();

      expect(resultado, isA<Failure>());
      final failure = resultado as Failure;
      expect(failure.error, isA<SinConectividadException>());
      verifyNever(mockApi.obtenerContenidoBienvenida());
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
