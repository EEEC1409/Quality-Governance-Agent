import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resuelve_app/adaptadores/gateways/contenido_marca_gateway.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/dominio/entidades/contenido_bienvenida.dart';
import 'package:resuelve_app/infraestructura/red/generated/api/marca_api.dart';

class _FakeMarcaApi extends MarcaApi {
  _FakeMarcaApi() : super(Dio());

  @override
  Future<Response<dynamic>> obtenerContenidoBienvenida() async {
    final opts = RequestOptions(path: '/v1/marca/contenido-bienvenida');
    return Response(
      data: {
        'logoUrl': 'https://assets.resuelve.com/logo.png',
        'videoUrl': 'https://assets.resuelve.com/video.mp4',
        'version': '2.1.0',
      },
      statusCode: 200,
      requestOptions: opts,
    );
  }
}

void main() {
  group('ContenidoMarcaGateway — integración mapeo DTO → dominio', () {
    test(
        'Dado que el servidor responde HTTP 200, '
        'Cuando se llama obtener(), '
        'Entonces mapea ContenidoBienvenidaResponse a la entidad de dominio', () async {
      final gateway = ContenidoMarcaGateway(_FakeMarcaApi());

      final resultado = await gateway.obtener();

      expect(resultado, isA<Success<ContenidoBienvenida>>());
      final success = resultado as Success<ContenidoBienvenida>;
      expect(success.value.logoUrl, 'https://assets.resuelve.com/logo.png');
      expect(success.value.videoUrl, 'https://assets.resuelve.com/video.mp4');
      expect(success.value.version, '2.1.0');
    });
  });
}
