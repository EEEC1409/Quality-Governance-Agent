// GENERATED CODE - DO NOT MODIFY BY HAND

class ErrorResponse {
  final String codigo;
  final String mensaje;
  final String timestamp;

  const ErrorResponse({
    required this.codigo,
    required this.mensaje,
    required this.timestamp,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      codigo: json['codigo'] as String,
      mensaje: json['mensaje'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}
