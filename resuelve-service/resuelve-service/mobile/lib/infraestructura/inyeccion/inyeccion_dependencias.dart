import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../adaptadores/gateways/contenido_marca_gateway.dart';
import '../../adaptadores/gateways/primer_uso_gateway.dart';
import '../../aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart';
import '../../aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart';
import '../../aplicacion/casos_de_uso/verificar_primer_uso_uc.dart';
import '../persistencia/primer_uso_shared_prefs.dart';
import '../red/generated/api/marca_api.dart';

final sl = GetIt.instance;

class InyeccionDependencias {
  static Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();

    // Infraestructura
    sl.registerSingleton<PrimerUsoSharedPrefs>(PrimerUsoSharedPrefs(prefs));

    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    sl.registerSingleton<MarcaApi>(MarcaApi(dio));

    // Adaptadores (gateways)
    sl.registerSingleton<PrimerUsoGateway>(PrimerUsoGateway(sl<PrimerUsoSharedPrefs>()));
    sl.registerSingleton<ContenidoMarcaGateway>(ContenidoMarcaGateway(sl<MarcaApi>()));

    // Casos de uso
    sl.registerFactory(() => VerificarPrimerUsoUC(repositorio: sl<PrimerUsoGateway>()));
    sl.registerFactory(() => MarcarBienvenidaVistaUC(repositorio: sl<PrimerUsoGateway>()));
    sl.registerFactory(() => ObtenerContenidoBienvenidaUC(repositorio: sl<ContenidoMarcaGateway>()));
  }
}
