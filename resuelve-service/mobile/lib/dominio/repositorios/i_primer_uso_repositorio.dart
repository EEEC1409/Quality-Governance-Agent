import '../entidades/estado_primer_uso.dart';

abstract interface class IPrimerUsoRepositorio {
  Future<EstadoPrimerUso> obtenerEstado();
  Future<void> marcarComoVisto();
}
