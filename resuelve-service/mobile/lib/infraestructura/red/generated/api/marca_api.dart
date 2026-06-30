// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:dio/dio.dart';
import '../model/contenido_bienvenida_response.dart';

class MarcaApi {
  final Dio _dio;

  MarcaApi(this._dio);

  Future<Response<ContenidoBienvenidaResponse>> obtenerContenidoBienvenida() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/marca/contenido-bienvenida');
    return Response(
      data: ContenidoBienvenidaResponse.fromJson(response.data!),
      statusCode: response.statusCode,
      requestOptions: response.requestOptions,
    );
  }
}
