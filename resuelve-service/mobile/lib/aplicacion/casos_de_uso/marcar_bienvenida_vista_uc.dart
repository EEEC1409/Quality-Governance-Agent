import '../../dominio/repositorios/i_primer_uso_repositorio.dart';

class MarcarBienvenidaVistaUC {
  final IPrimerUsoRepositorio _repositorio;

  const MarcarBienvenidaVistaUC({required IPrimerUsoRepositorio repositorio})
      : _repositorio = repositorio;

  Future<void> ejecutar() => _repositorio.marcarComoVisto();
}
