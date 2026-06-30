import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resuelve_app/dominio/repositorios/i_primer_uso_repositorio.dart';
import 'package:resuelve_app/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';

import 'marcar_bienvenida_vista_uc_test.mocks.dart';

@GenerateMocks([IPrimerUsoRepositorio])
void main() {
  late MockIPrimerUsoRepositorio mockRepositorio;
  late MarcarBienvenidaVistaUC uc;

  setUp(() {
    mockRepositorio = MockIPrimerUsoRepositorio();
    uc = MarcarBienvenidaVistaUC(repositorio: mockRepositorio);
  });

  group('MarcarBienvenidaVistaUC', () {
    test(
        'Dado que el repositorio recibe la llamada, '
        'Cuando se ejecuta el UC, '
        'Entonces invoca marcarComoVisto exactamente una vez y completa sin error', () async {
      when(mockRepositorio.marcarComoVisto()).thenAnswer((_) async {});

      await expectLater(uc.ejecutar(), completes);

      verify(mockRepositorio.marcarComoVisto()).called(1);
    });
  });
}
