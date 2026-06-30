# language: es
Característica: Contenido de bienvenida de la marca Resuelve
  Como cliente de la aplicación móvil
  Quiero obtener el contenido de bienvenida desde el backend
  Para mostrar el logo y el video de marca en la pantalla inicial

  Escenario: Obtener contenido de bienvenida exitosamente
    Dado que existe contenido de bienvenida activo en la base de datos
    Cuando se realiza GET /v1/marca/contenido-bienvenida
    Entonces la respuesta tiene código HTTP 200
    Y el cuerpo contiene logoUrl, videoUrl y version
    Y el cuerpo cumple el esquema OpenAPI de ContenidoBienvenidaResponse

  Escenario: El servicio retorna 404 cuando no existe contenido activo
    Dado que no existe ningún registro activo en la base de datos
    Cuando se realiza GET /v1/marca/contenido-bienvenida
    Entonces la respuesta tiene código HTTP 404
    Y el cuerpo contiene el campo codigo con valor "CONTENIDO_NO_ENCONTRADO"
