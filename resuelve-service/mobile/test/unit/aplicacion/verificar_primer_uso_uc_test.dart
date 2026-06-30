import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/dominio/entidades/estado_primer_uso.dart';
import 'package:resuelve_app/dominio/repositorios/i_primer_uso_repositorio.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/verificar_primer_uso_uc.dart';

import 'verificar_primer_uso_uc_test.mocks.dart';

@GenerateMocks([IPrimerUsoRepositorio])
void main() {
  late MockIPrimerUsoRepositorio mockRepositorio;
  late VerificarPrimerUsoUC uc;

  setUp(() {
    mockRepositorio = MockIPrimerUsoRepositorio();
    uc = VerificarPrimerUsoUC(repositorio: mockRepositorio);
  });

  group('VerificarPrimerUsoUC', () {
    test(
        'Dado que bienvenidaVista es false, '
        'Cuando se ejecuta el UC, '
        'Entonces retorna true (debe mostrar bienvenida)', () async {
      when(mockRepositorio.obtenerEstado()).thenAnswer(
        (_) async => const EstadoPrimerUso(bienvenidaVista: false),
      );

      final resultado = await uc.ejecutar();

      expect(resultado, isTrue);
      verify(mockRepositorio.obtenerEstado()).called(1);
    });

    test(
        'Dado que bienvenidaVista es true, '
        'Cuando se ejecuta el UC, '
        'Entonces retorna false (no mostrar bienvenida)', () async {
      when(mockRepositorio.obtenerEstado()).thenAnswer(
        (_) async => const EstadoPrimerUso(bienvenidaVista: true),
      );

      final resultado = await uc.ejecutar();

      expect(resultado, isFalse);
      verify(mockRepositorio.obtenerEstado()).called(1);
    });
  });
}
