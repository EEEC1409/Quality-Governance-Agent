class SinConectividadException implements Exception {
  const SinConectividadException();
  @override
  String toString() => 'SinConectividadException: sin acceso a la red';
}

class ErrorCdnException implements Exception {
  final int statusCode;
  const ErrorCdnException(this.statusCode);
  @override
  String toString() => 'ErrorCdnException: HTTP $statusCode';
}

class ContenidoNoEncontradoException implements Exception {
  const ContenidoNoEncontradoException();
}
