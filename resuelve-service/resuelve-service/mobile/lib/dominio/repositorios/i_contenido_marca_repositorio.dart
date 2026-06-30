import '../entidades/contenido_bienvenida.dart';
import '../entidades/result.dart';

abstract interface class IContenidoMarcaRepositorio {
  Future<Result<ContenidoBienvenida>> obtener();
}
