import '../../dominio/entidades/estado_primer_uso.dart';
import '../../dominio/repositorios/i_primer_uso_repositorio.dart';
import '../../infraestructura/persistencia/primer_uso_shared_prefs.dart';

class PrimerUsoGateway implements IPrimerUsoRepositorio {
  final PrimerUsoSharedPrefs _prefs;

  const PrimerUsoGateway(this._prefs);

  @override
  Future<EstadoPrimerUso> obtenerEstado() async {
    return EstadoPrimerUso(bienvenidaVista: _prefs.obtenerBienvenidaVista());
  }

  @override
  Future<void> marcarComoVisto() => _prefs.marcarComoVisto();
}
