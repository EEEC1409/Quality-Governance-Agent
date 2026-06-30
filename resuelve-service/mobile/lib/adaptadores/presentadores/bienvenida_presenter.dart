import 'package:flutter/foundation.dart';

import '../../aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import '../../aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import '../../dominio/entidades/result.dart';

sealed class BienvenidaEstado {}

class BienvenidaCargando extends BienvenidaEstado {}

class BienvenidaConContenido extends BienvenidaEstado {
  final String logoUrl;
  final String videoUrl;
  BienvenidaConContenido({required this.logoUrl, required this.videoUrl});
}

class BienvenidaSinVideo extends BienvenidaEstado {}

class BienvenidaPresenter extends ChangeNotifier {
  final ObtenerContenidoBienvenidaUC _obtenerContenidoUC;
  final MarcarBienvenidaVistaUC _marcarVistaUC;

  BienvenidaEstado _estado = BienvenidaCargando();
  BienvenidaEstado get estado => _estado;

  BienvenidaPresenter({
    required ObtenerContenidoBienvenidaUC obtenerContenidoUC,
    required MarcarBienvenidaVistaUC marcarVistaUC,
  })  : _obtenerContenidoUC = obtenerContenidoUC,
        _marcarVistaUC = marcarVistaUC;

  Future<void> cargar() async {
    _estado = BienvenidaCargando();
    notifyListeners();

    final resultado = await _obtenerContenidoUC.ejecutar();
    switch (resultado) {
      case Success(:final value):
        _estado = BienvenidaConContenido(
          logoUrl: value.logoUrl,
          videoUrl: value.videoUrl,
        );
      case Failure():
        _estado = BienvenidaSinVideo();
    }
    notifyListeners();
  }

  Future<void> continuar() async {
    await _marcarVistaUC.ejecutar();
  }
}
