# Investigación: Pantalla de Bienvenida con Video de Marca

**Fecha**: 2026-06-27
**Funcionalidad**: US-01 · EPIC-01

---

## Decisión 1: Plataforma Móvil

**Decisión**: Flutter 3.x + Dart 3.x (cross-platform iOS + Android)

**Justificación**:
- Único codebase para iOS y Android; reduce el tiempo de desarrollo a la mitad respecto a
  desarrollo nativo separado.
- El paquete `video_player` (oficial de Flutter) soporta reproducción de video desde URL remota
  en ambas plataformas con una API unificada.
- `connectivity_plus` provee detección de estado de red en tiempo real (WiFi, móvil, sin red)
  con una interfaz Stream reactiva que se integra de forma natural con Flutter.
- Amplia adopción en aplicaciones financieras en Latinoamérica.

**Alternativas consideradas**:
- React Native: descartado por mayor complejidad de configuración de video nativo y menor
  alineación con Arquitectura Limpia en Dart.
- Kotlin Multiplatform Mobile: descartado por madurez del tooling BDD en comparación con Flutter.
- Nativo (Swift + Kotlin separados): descartado por duplicación de código, contrario a DRY.

---

## Decisión 2: Backend Framework

**Decisión**: Java 17 + Spring Boot 3.x con springdoc-openapi 2.x

**Justificación**:
- Spring Boot genera automáticamente la especificación OpenAPI 3.0 desde anotaciones, alineado
  con el Principio IV (API-First).
- Java 17 (LTS) garantiza soporte a largo plazo; Spring Boot 3.x requiere Java 17 como mínimo.
- JaCoCo está integrado nativamente en el ecosistema Gradle/Maven de Spring Boot, alineado con
  el Principio V.
- Amplio soporte de Cucumber 7 en el ecosistema JVM para pruebas BDD (Principio II).

**Alternativas consideradas**:
- Node.js/Express: descartado por menor soporte nativo de JaCoCo y menor ecosistema BDD empresarial.
- Quarkus: descartado por menor familiaridad en el equipo y curva de aprendizaje adicional.

---

## Decisión 3: Reproducción de Video

**Decisión**: Paquete `video_player` ^2.x (Flutter oficial) con carga desde URL remota

**Justificación**:
- Soporta streaming desde URL (HTTP/HTTPS) en iOS y Android sin configuración adicional.
- Manejo nativo de estados: `buffering`, `playing`, `paused`, `error`.
- Permite detectar el evento `onVideoEnd` para la navegación automática (escenario BDD 1.2).
- Ligero: no incluye codecs adicionales que inflen el tamaño del APK/IPA.

**Patrón de degradación offline**:
- Al inicializar el `VideoPlayerController`, si `connectivity_plus` detecta `ConnectivityResult.none`,
  se omite la inicialización del video y se muestra únicamente el logo + botón "Continuar".
- Si la carga del video falla (timeout, 404), se captura la excepción en el Gateway y se emite
  un `Result.failure` que el Presentador traduce a "mostrar solo logo + continuar".
- En ningún caso se propaga un mensaje de error al usuario (RF-005).

---

## Decisión 4: Persistencia del Estado de Primer Uso

**Decisión**: `shared_preferences` ^2.x para persistir el flag `primer_uso_completado`

**Justificación**:
- Estándar de facto en Flutter para almacenamiento clave-valor ligero en el dispositivo.
- El flag se escribe al completar la navegación a la pantalla de cédula (RF-006); no antes,
  para que un cierre forzado durante la bienvenida muestre la pantalla nuevamente.
- La lectura del flag ocurre en `VerificarPrimerUsoUC` (Caso de Uso), no en la UI.

---

## Decisión 5: Estrategia de Pruebas BDD

**Decisión**:
- **Unitarias**: `flutter_test` (integrado en SDK) + `mockito` para dobles de prueba de
  repositorios e interfaces de Casos de Uso.
- **Integración**: `flutter_test` con implementaciones reales en memoria de los repositorios
  (sin flutter_driver ni emulador).
- **Funcionales**: `integration_test` package (oficial Flutter) + `bdd_widget_test` ^2.x
  para expresar escenarios en formato Gherkin directamente en Dart.
- **Cobertura**: `flutter test --coverage` genera `lcov.info`; `genhtml` produce reporte HTML.

**Backend**:
- **Unitarias + Integración**: JUnit 5 + Mockito + MockMvc.
- **Funcionales BDD**: Cucumber 7 con archivos `.feature` en Gherkin español.
- **Cobertura**: JaCoCo plugin Gradle con reglas `≥ 80%` por clase y global.

---

## Decisión 6: Generación del Cliente OpenAPI para Flutter

**Decisión**: `openapi-generator-cli` con generador `dart-dio`

**Justificación**:
- Genera un cliente Dart tipado usando `dio` como transporte HTTP.
- El cliente generado se ubica en `mobile/lib/infraestructura/red/` y NO se modifica manualmente.
- La regeneración se ejecuta desde `openapitools.json` en la raíz del proyecto con el comando:
  `openapi-generator-cli generate -i specs/001-bienvenida-video-marca/contracts/openapi.yml -g dart-dio -o mobile/lib/infraestructura/red/`

---

## Decisión 7: Persistencia Backend y Gestión de Esquema

**Decisión**: Spring Data JPA + Flyway + PostgreSQL (producción) / H2 (tests)

**Justificación**:
- El contenido de bienvenida (logoUrl, videoUrl, version) se almacena en base de datos para
  permitir actualizaciones sin redespliegue de la aplicación.
- **Flyway** gestiona las migraciones de esquema con versionado explícito (`V1__`, `V2__`, etc.)
  y datos precargados con migraciones repetibles (`R__`). Esto garantiza reproducibilidad en
  todos los entornos (desarrollo, CI, producción).
- **H2 in-memory** en el perfil `test` permite ejecutar la suite de pruebas sin dependencias
  externas, acelerando CI. Flyway crea el esquema y carga los datos de prueba automáticamente
  al levantar el contexto de Spring.
- **PostgreSQL** en producción y staging para consistencia con entornos reales.

**Estructura de recursos**:
```
src/main/resources/db/
├── migration/V1__crear_tabla_contenido_marca.sql   # DDL — esquema de tabla
└── data/R__seed_contenido_marca.sql                # DML — datos iniciales precargados

src/test/resources/db/test-data/
└── contenido_marca_test_data.sql                   # Datos específicos para pruebas BDD
```

**Convención de nombrado Flyway**:
- `V{version}__{descripcion}.sql` — migraciones versionadas (DDL, cambios de esquema)
- `R__{descripcion}.sql` — migraciones repetibles (datos de referencia/semilla, se re-ejecutan
  cuando cambia el checksum del archivo)

**Alternativas consideradas**:
- Liquibase: descartado por mayor verbosidad (XML/YAML) frente a SQL puro de Flyway.
- Solo `application.yml` con valores hardcodeados: descartado porque no permite actualizar
  el contenido sin redespliegue; viola el principio de separación de configuración y código.
- `data.sql` de Spring Boot: descartado porque no versiona ni audita los cambios; Flyway
  es la alternativa recomendada para entornos con CI/CD.

---

## Resumen de Decisiones

| Aspecto | Decisión |
|---------|----------|
| Plataforma móvil | Flutter 3.x + Dart 3.x |
| Backend | Java 17 + Spring Boot 3.x |
| Persistencia backend | Spring Data JPA + Flyway + PostgreSQL (prod) / H2 (test) |
| Video | video_player ^2.x (URL remota) |
| Conectividad | connectivity_plus ^6.x |
| Primer uso | shared_preferences ^2.x |
| Pruebas móvil | flutter_test + bdd_widget_test + integration_test |
| Pruebas backend | JUnit 5 + Cucumber 7 |
| Cobertura móvil | lcov (≥ 80% clase y global) |
| Cobertura backend | JaCoCo (≥ 80% clase y global) |
| Cliente API | openapi-generator dart-dio |
