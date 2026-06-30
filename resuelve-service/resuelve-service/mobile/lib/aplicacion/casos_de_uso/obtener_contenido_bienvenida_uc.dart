import '../../dominio/entidades/contenido_bienvenida.dart';
import '../../dominio/entidades/result.dart';
import '../../dominio/repositorios/i_contenido_marca_repositorio.dart';

class ObtenerContenidoBienvenidaUC {
  final IContenidoMarcaRepositorio _repositorio;

  const ObtenerContenidoBienvenidaUC({required IContenidoMarcaRepositorio repositorio})
      : _repositorio = repositorio;

  Future<Result<ContenidoBienvenida>> ejecutar() => _repositorio.obtener();
}
