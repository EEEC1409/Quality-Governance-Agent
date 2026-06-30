# Guía de Validación: Pantalla de Bienvenida con Video de Marca

**Fecha**: 2026-06-27
**Funcionalidad**: US-01 · EPIC-01

Esta guía describe cómo ejecutar y verificar que la funcionalidad US-01 está implementada
correctamente. No contiene código de implementación; refiérase a `tasks.md` para las tareas
concretas de desarrollo.

---

## Prerequisitos

| Herramienta | Versión mínima | Verificar con |
|-------------|----------------|---------------|
| Flutter SDK | 3.x | `flutter --version` |
| Dart SDK | 3.x (incluido en Flutter) | `dart --version` |
| Java JDK | 17 | `java -version` |
| Gradle | 8.x | `./gradlew --version` |
| openapi-generator-cli | 7.x | `openapi-generator-cli version` |

---

## Escenario 1: Primer arranque con conexión activa

**Referencia BDD**: Historia de Usuario 1, Escenarios 1.1 → 1.3

### Pasos

1. Instalar la APP en un emulador/dispositivo con conexión activa.
2. Asegurarse de que no existe el flag `primer_uso_completado` en el dispositivo
   (instalación limpia o limpiar datos de la APP).
3. Abrir la APP.

### Resultados esperados

- El logo de Resuelve aparece en ≤ 2 segundos desde el arranque (CE-003).
- El video de marca comienza a reproducirse automáticamente sin intervención del usuario.
- Al terminar el video, la APP navega sola a la pantalla de ingreso de cédula.
- Al tocar "Continuar" antes de que termine el video, la APP navega inmediatamente a la
  pantalla de ingreso de cédula.
- No se muestra ningún mensaje de error en ningún momento.

### Comando de prueba funcional

```bash
cd mobile
flutter test test/functional/bdd/bienvenida_con_conexion_test.dart
```

---

## Escenario 2: Primer arranque sin conexión (modo avión)

**Referencia BDD**: Historia de Usuario 2, Escenarios 2.1 → 2.3

### Pasos

1. Activar el modo avión en el emulador/dispositivo.
2. Asegurarse de que no existe el flag `primer_uso_completado` (instalación limpia).
3. Abrir la APP.

### Resultados esperados

- El logo de Resuelve es visible en ≤ 2 segundos.
- El video NO se reproduce; no se muestra error por ello.
- El botón "Continuar" está habilitado y visible.
- Al tocar "Continuar", la APP navega a la pantalla de ingreso de cédula.

### Comando de prueba funcional

```bash
cd mobile
flutter test test/functional/bdd/bienvenida_sin_conexion_test.dart
```

---

## Escenario 3: Segundo acceso (bienvenida ya vista)

**Referencia**: RF-006

### Pasos

1. Completar el Escenario 1 o 2 (el flag `primer_uso_completado` quedó en `true`).
2. Cerrar la APP completamente.
3. Volver a abrir la APP.

### Resultado esperado

- La APP NO muestra la pantalla de bienvenida.
- La APP navega directamente al flujo de autenticación o pantalla de cédula.

### Comando de prueba funcional

```bash
cd mobile
flutter test test/functional/bdd/segundo_acceso_test.dart
```

---

## Troubleshooting

### Flyway — "Migration checksum mismatch"

**Causa**: Se modificó un archivo de migración ya aplicado (V1__ o R__).
**Solución**: Para H2 en tests, limpiar el estado: `./gradlew flywayClean flywayMigrate` o borrar el contexto de Spring en tests con `@DirtiesContext`.

### Flyway — "Table 'contenido_bienvenida' already exists" en H2

**Causa**: El modo H2 `MODE=PostgreSQL` no tiene soporte para todos los tipos de DDL de PostgreSQL.
**Solución**: Verificar que el JDBC URL incluye `MODE=PostgreSQL` y `NON_KEYWORDS=VALUE` en `application-test.yml`.

### Flutter — "MissingPluginException" para video_player en tests

**Causa**: Los plugins nativos no están disponibles en Flutter widget tests.
**Solución**: La `BienvenidaScreen` maneja fallos de `VideoPlayerController.initialize()` silenciosamente vía `catchError`. Los tests deben mockear el `BienvenidaPresenter` y no el `VideoPlayerController` directamente.

### Flutter — Tests mockito con "Null check operator"

**Causa**: Los mocks generados con `@GenerateMocks` no están generados aún.
**Solución**: Ejecutar `flutter pub run build_runner build` desde `mobile/` antes de correr los tests.

### openapi-generator-cli — "Generator 'dart-dio' not found"

**Causa**: openapi-generator-cli no está instalado globalmente.
**Solución**: `npm install -g @openapitools/openapi-generator-cli` y volver a ejecutar el comando de generación.

---

## Validación del Endpoint Backend

**Referencia**: Principio IV — API-First, contrato en `contracts/openapi.yml`

### Iniciar el backend localmente

```bash
cd backend
./gradlew bootRun
```

### Verificar el endpoint con curl

```bash
curl -s http://localhost:8080/v1/marca/contenido-bienvenida | jq .
```

**Respuesta esperada** (HTTP 200):

```json
{
  "logoUrl": "https://assets.resuelve.com/marca/logo-principal.png",
  "videoUrl": "https://assets.resuelve.com/marca/video-bienvenida-v2.mp4",
  "version": "2.1.0"
}
```

### Verificar que la respuesta cumple el esquema OpenAPI

```bash
cd backend
./gradlew test --tests "*MarcaControllerFuncionalTest"
```

---

## Ejecución Completa de la Suite de Pruebas

### Backend

```bash
cd backend
./gradlew test jacocoTestReport
```

- Reporte JUnit XML: `backend/build/test-results/test/`
- Reporte HTML cobertura: `backend/build/reports/jacoco/test/html/index.html`
- Umbral mínimo por clase: 80% | Umbral global: 80%

### Móvil Flutter

```bash
cd mobile
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

- Reporte JUnit XML: generado con `flutter test --reporter json`
- Reporte HTML cobertura: `mobile/coverage/html/index.html`
- Umbral mínimo por clase: 80% | Umbral global: 80%

---

## Regenerar el Cliente API desde el Contrato OpenAPI

Si el contrato `contracts/openapi.yml` fue modificado, regenerar el cliente Dart:

```bash
openapi-generator-cli generate \
  -i specs/001-bienvenida-video-marca/contracts/openapi.yml \
  -g dart-dio \
  -o mobile/lib/infraestructura/red/generated/ \
  --additional-properties=pubName=resuelve_api_client
```

**Importante**: El código en `mobile/lib/infraestructura/red/generated/` es generado.
No modificar manualmente; los cambios se pierden al regenerar.

---

## Criterios de Aceptación Técnicos

| Criterio | Cómo verificar |
|----------|----------------|
| Cobertura por clase ≥ 80% | Reporte JaCoCo / lcov |
| Cobertura global ≥ 80% | Reporte JaCoCo / lcov |
| Respuesta backend ≤ 500 ms p95 | Logs de Spring Boot / prueba de rendimiento |
| Logo visible ≤ 2 s | Prueba funcional con timer en `integration_test` |
| Sin mensajes de error offline | Prueba funcional Escenario 2 |
| Cliente Dart generado desde OpenAPI | Verificar que `generated/` no tiene ediciones manuales |
