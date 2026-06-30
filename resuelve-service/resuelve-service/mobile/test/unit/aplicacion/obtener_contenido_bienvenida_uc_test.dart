import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/dominio/entidades/contenido_bienvenida.dart';
import 'package:resuelve_app/dominio/entidades/result.dart';
import 'package:resuelve_app/dominio/repositorios/i_contenido_marca_repositorio.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';

import 'obtener_contenido_bienvenida_uc_test.mocks.dart';

@GenerateMocks([IContenidoMarcaRepositorio])
void main() {
  late MockIContenidoMarcaRepositorio mockRepositorio;
  late ObtenerContenidoBienvenidaUC uc;

  setUp(() {
    mockRepositorio = MockIContenidoMarcaRepositorio();
    uc = ObtenerContenidoBienvenidaUC(repositorio: mockRepositorio);
  });

  group('ObtenerContenidoBienvenidaUC', () {
    test(
        'Dado que el repositorio retorna Success, '
        'Cuando se ejecuta el UC, '
        'Entonces delega al repositorio y retorna Result<ContenidoBienvenida>', () async {
      const contenido = ContenidoBienvenida(
        logoUrl: 'https://assets.resuelve.com/logo.png',
        videoUrl: 'https://assets.resuelve.com/video.mp4',
        version: '2.1.0',
      );
      when(mockRepositorio.obtener())
          .thenAnswer((_) async => const Success(contenido));

      final resultado = await uc.ejecutar();

      expect(resultado, isA<Success<ContenidoBienvenida>>());
      final success = resultado as Success<ContenidoBienvenida>;
      expect(success.value.logoUrl, 'https://assets.resuelve.com/logo.png');
      verify(mockRepositorio.obtener()).called(1);
    });

    test(
        'Dado que el repositorio retorna Failure, '
        'Cuando se ejecuta el UC, '
        'Entonces retorna Failure sin propagar excepción', () async {
      when(mockRepositorio.obtener())
          .thenAnswer((_) async => Failure(Exception('red no disponible')));

      final resultado = await uc.ejecutar();

      expect(resultado, isA<Failure<ContenidoBienvenida>>());
      verify(mockRepositorio.obtener()).called(1);
    });
  });
}
