import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../dominio/entidades/contenido_bienvenida.dart';
import '../../dominio/entidades/excepciones.dart';
import '../../dominio/entidades/result.dart';
import '../../dominio/repositorios/i_contenido_marca_repositorio.dart';
import '../../infraestructura/red/generated/api/marca_api.dart';
import '../../infraestructura/red/generated/model/contenido_bienvenida_response.dart';

class ContenidoMarcaGateway implements IContenidoMarcaRepositorio {
  final MarcaApi _api;

  const ContenidoMarcaGateway(this._api);

  @override
  Future<Result<ContenidoBienvenida>> obtener() async {
    final conectividad = await Connectivity().checkConnectivity();
    if (conectividad.contains(ConnectivityResult.none) ||
        conectividad.isEmpty) {
      return Failure(const SinConectividadException());
    }

    try {
      final response = await _api.obtenerContenidoBienvenida();
      final data = response.data;

      if (response.statusCode != 200 || data == null) {
        return Failure(ErrorCdnException(response.statusCode ?? 0));
      }

      final dto = data is ContenidoBienvenidaResponse
          ? data
          : ContenidoBienvenidaResponse.fromJson(data as Map<String, dynamic>);

      return Success(ContenidoBienvenida(
        logoUrl: dto.logoUrl,
        videoUrl: dto.videoUrl,
        version: dto.version,
      ));
    } on TimeoutException catch (e) {
      return Failure(e);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Failure(TimeoutException('timeout al conectar con el servidor'));
      }
      if (e.response != null) {
        return Failure(ErrorCdnException(e.response!.statusCode ?? 0));
      }
      return Failure(const SinConectividadException());
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
