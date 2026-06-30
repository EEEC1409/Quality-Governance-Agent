import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resuelve_app/infraestructura/persistencia/primer_uso_shared_prefs.dart';
import 'package:resuelve_app/adaptadores/gateways/primer_uso_gateway.dart';

void main() {
  group('PrimerUsoGateway — integración con SharedPreferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'Dado que la clave no existe en SharedPreferences, '
        'Cuando se llama obtenerEstado(), '
        'Entonces retorna EstadoPrimerUso(bienvenidaVista: false)', () async {
      final prefs = await SharedPreferences.getInstance();
      final gateway = PrimerUsoGateway(PrimerUsoSharedPrefs(prefs));

      final estado = await gateway.obtenerEstado();

      expect(estado.bienvenidaVista, isFalse);
    });

    test(
        'Dado que se llamó marcarComoVisto(), '
        'Cuando se llama obtenerEstado() nuevamente, '
        'Entonces retorna EstadoPrimerUso(bienvenidaVista: true)', () async {
      final prefs = await SharedPreferences.getInstance();
      final gateway = PrimerUsoGateway(PrimerUsoSharedPrefs(prefs));

      await gateway.marcarComoVisto();
      final estado = await gateway.obtenerEstado();

      expect(estado.bienvenidaVista, isTrue);
    });
  });
}
