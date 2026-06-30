import '../../dominio/repositorios/i_primer_uso_repositorio.dart';

class VerificarPrimerUsoUC {
  final IPrimerUsoRepositorio _repositorio;

  const VerificarPrimerUsoUC({required IPrimerUsoRepositorio repositorio})
      : _repositorio = repositorio;

  Future<bool> ejecutar() async {
    final estado = await _repositorio.obtenerEstado();
    return !estado.bienvenidaVista;
  }
}
