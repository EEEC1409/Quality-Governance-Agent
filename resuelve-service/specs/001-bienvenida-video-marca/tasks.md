---
description: "Lista de tareas para US-01 · Pantalla de Bienvenida con Video de Marca · EPIC-01"
---

# Tareas: Pantalla de Bienvenida con Video de Marca

**Entrada**: Artefactos de diseño en `specs/001-bienvenida-video-marca/`

**Requisitos previos**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Pruebas**: Las pruebas BDD son OBLIGATORIAS por la Constitución (Principio II). Se escriben ANTES de la implementación (TDD — Red primero, luego Green).

**Remediación aplicada** (análisis `/speckit-analyze`):
- C1: Añadidas pruebas unitarias para `VerificarPrimerUsoUC` y `MarcarBienvenidaVistaUC` (T014, T015) antes de su implementación (T017)
- C2: Añadida prueba funcional con aserción de tiempo ≤ 2 s para el logo (T026) en Fase 3 US1
- H1: Añadida prueba de integración para `PrimerUsoGateway` (T016) antes de su implementación (T018)
- H2: Añadidas pruebas de integración para pérdida de red mid-stream (T039) y CDN 404/500 (T040) en Fase 4 US2

## Formato: `[ID] [P?] [Historia?] Descripción con ruta de archivo`

- **[P]**: Puede ejecutarse en paralelo (archivos distintos, sin dependencias pendientes)
- **[Historia]**: Historia de usuario a la que pertenece ([US1], [US2])
- Incluir rutas exactas de archivos en todas las descripciones

## Convenciones de Rutas

- **Backend fuente**: `backend/src/main/java/com/resuelve/`
- **Backend recursos**: `backend/src/main/resources/`
- **Backend pruebas fuente**: `backend/src/test/java/com/resuelve/`
- **Backend pruebas recursos**: `backend/src/test/resources/`
- **Móvil fuente**: `mobile/lib/`
- **Móvil pruebas**: `mobile/test/`

---

## Fase 1: Setup (Infraestructura Inicial)

**Propósito**: Inicialización del proyecto, estructura de directorios y configuración base

- [X] T001 Crear estructura de directorios completa según plan.md: `backend/` con subcarpetas por capa (dominio, aplicacion, adaptadores, infraestructura) y subdirectorios `src/main/resources/db/migration/`, `src/main/resources/db/data/`, `src/test/resources/db/test-data/`, `src/test/resources/features/marca/`; `mobile/` con subdirectorios por capa y `test/unit/`, `test/integration/`, `test/functional/bdd/`
- [X] T002 [P] Inicializar proyecto Spring Boot 3.x en `backend/build.gradle` con dependencias: spring-web, spring-validation, springdoc-openapi 2.x, spring-data-jpa, flyway-core, postgresql, h2 (testImplementation), cucumber-spring, cucumber-java, junit-platform-launcher, rest-assured:5.x (testImplementation), json-schema-validator:5.x (testImplementation para validar respuestas contra el esquema OpenAPI), jacoco plugin
- [X] T003 [P] Inicializar proyecto Flutter 3.x en `mobile/pubspec.yaml` con dependencias: video_player ^2.x, connectivity_plus ^6.x, dio ^5.x, shared_preferences ^2.x, get_it ^7.x, bdd_widget_test ^2.x, integration_test (dev_dependency), mockito, build_runner
- [X] T004 [P] Crear archivos de configuración Spring Boot: `backend/src/main/resources/application.yml` (datasource PostgreSQL con variables DB_URL, DB_USER, DB_PASSWORD; flyway locations: classpath:db/migration,classpath:db/data), `backend/src/main/resources/application-local.yml` (H2 o PostgreSQL local), `backend/src/test/resources/application-test.yml` (H2 in-memory MODE=PostgreSQL; flyway locations incluyendo classpath:db/test-data)
- [X] T005 [P] Configurar `openapitools.json` en raíz del repositorio con generador `dart-dio`, input `specs/001-bienvenida-video-marca/contracts/openapi.yml`, output `mobile/lib/infraestructura/red/generated/`, additionalProperties pubName=resuelve_api_client
- [X] T006 [P] Configurar herramientas de cobertura: bloque `jacocoTestCoverageVerification` en `backend/build.gradle` con límites minimumBranchCoverage=0.80 y minimumLineCoverage=0.80 por clase y global; crear `mobile/Makefile` con targets `test-coverage` y `coverage-report` usando `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

---

## Fase 2: Fundamentos (Bloqueantes para Todas las Historias)

**Propósito**: Esquema de base de datos, entidades, interfaces, pruebas unitarias y de integración de la infraestructura compartida que DEBEN estar completos antes de cualquier historia de usuario

**⚠️ CRÍTICO**: Ningún trabajo de historia de usuario puede comenzar hasta completar esta fase

- [X] T007 Generar cliente Dart desde `specs/001-bienvenida-video-marca/contracts/openapi.yml` ejecutando `openapi-generator-cli generate -i specs/001-bienvenida-video-marca/contracts/openapi.yml -g dart-dio -o mobile/lib/infraestructura/red/generated/ --additional-properties=pubName=resuelve_api_client`
- [X] T008 [P] Crear migración Flyway de esquema en `backend/src/main/resources/db/migration/V1__crear_tabla_contenido_marca.sql` con DDL de la tabla `contenido_bienvenida` (campos: id BIGINT PK, logo_url VARCHAR(500) NOT NULL, video_url VARCHAR(500) NOT NULL, version VARCHAR(50) NOT NULL, activo BOOLEAN DEFAULT TRUE, creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP; constraints CHECK https en logo_url y video_url)
- [X] T009 [P] Crear migración Flyway de datos precargados en `backend/src/main/resources/db/data/R__seed_contenido_marca.sql` con sentencia `INSERT INTO contenido_bienvenida ... ON CONFLICT (id) DO UPDATE SET ...` compatible con PostgreSQL y H2 (MODE=PostgreSQL)
- [X] T010 [P] Crear datos de prueba BD en `backend/src/test/resources/db/test-data/contenido_marca_test_data.sql` con registro de prueba (id=99, URLs de test-assets.resuelve.com, version='0.0.1-TEST', activo=FALSE) para uso exclusivo en pruebas BDD e integración
- [X] T011 [P] Crear entidad de dominio backend `ContenidoBienvenida` en `backend/src/main/java/com/resuelve/dominio/marca/ContenidoBienvenida.java` (clase Java pura sin anotaciones JPA: campos logoUrl, videoUrl, version; sin dependencias de framework)
- [X] T012 [P] Crear entidades de dominio móvil: `ContenidoBienvenida` en `mobile/lib/dominio/entidades/contenido_bienvenida.dart` y `EstadoPrimerUso` en `mobile/lib/dominio/entidades/estado_primer_uso.dart` (clases Dart puras sin dependencias de framework)
- [X] T013 [P] Crear interfaces de repositorio en mobile: `IContenidoMarcaRepositorio` en `mobile/lib/dominio/repositorios/i_contenido_marca_repositorio.dart` (método `obtener(): Future<Result<ContenidoBienvenida>>`) e `IPrimerUsoRepositorio` en `mobile/lib/dominio/repositorios/i_primer_uso_repositorio.dart` (métodos `obtenerEstado()` y `marcarComoVisto()`)

> **⚠️ REMEDIACIÓN C1 + H1 — ESCRIBIR PRIMERO, CONFIRMAR QUE FALLAN**

- [X] T014 [P] Crear prueba unitaria `VerificarPrimerUsoUCTest` en `mobile/test/unit/aplicacion/verificar_primer_uso_uc_test.dart`: Dado que `IPrimerUsoRepositorio` retorna `EstadoPrimerUso(bienvenidaVista: false)`, el UC retorna `true` (debe mostrar bienvenida); Dado que retorna `bienvenidaVista: true`, el UC retorna `false` (no mostrar); usando mock Mockito de `IPrimerUsoRepositorio`
- [X] T015 [P] Crear prueba unitaria `MarcarBienvenidaVistaUCTest` en `mobile/test/unit/aplicacion/marcar_bienvenida_vista_uc_test.dart`: verificar que el UC invoca `IPrimerUsoRepositorio.marcarComoVisto()` exactamente una vez y que el Future completa sin excepciones; usando mock Mockito de `IPrimerUsoRepositorio`
- [X] T016 [P] Crear prueba de integración `PrimerUsoGatewayTest` en `mobile/test/integration/adaptadores/primer_uso_gateway_test.dart`: verificar que `obtenerEstado()` retorna `EstadoPrimerUso(bienvenidaVista: false)` cuando la clave no existe en `shared_preferences`; verificar que después de `marcarComoVisto()`, `obtenerEstado()` retorna `bienvenidaVista: true`; usando instancia real de `SharedPreferences` con `SharedPreferences.setMockInitialValues({})`

- [X] T017 Implementar Casos de Uso de primer uso: `VerificarPrimerUsoUC` en `mobile/lib/aplicacion/casos_de_uso/verificar_primer_uso_uc.dart` y `MarcarBienvenidaVistaUC` en `mobile/lib/aplicacion/casos_de_uso/marcar_bienvenida_vista_uc.dart` (dependen de T014 y T015 fallando)
- [X] T018 [P] Implementar infraestructura de primer uso: `PrimerUsoSharedPrefs` en `mobile/lib/infraestructura/persistencia/primer_uso_shared_prefs.dart` (usa shared_preferences) y `PrimerUsoGateway` en `mobile/lib/adaptadores/gateways/primer_uso_gateway.dart` (implementa `IPrimerUsoRepositorio`; depende T016 fallando)
- [X] T019 Configurar inyección de dependencias con `get_it` en `mobile/lib/infraestructura/inyeccion/inyeccion_dependencias.dart` registrando: PrimerUsoSharedPrefs, PrimerUsoGateway, VerificarPrimerUsoUC, MarcarBienvenidaVistaUC (depende T017, T018)

**Checkpoint**: Fundamentos listos — implementación de historias de usuario puede comenzar

---

## Fase 3: Historia de Usuario 1 — Primer Acceso con Conexión (Prioridad: P1) 🎯 MVP

**Meta**: El cliente ve el logo ≤ 2 s, el video reproduce automáticamente y puede navegar a la pantalla de cédula al finalizar el video o tocar "Continuar"

**Prueba Independiente**: Instalar APP en emulador con conexión; verificar logo visible, video auto-reproduce, "Continuar" navega a pantalla de cédula, logo renderizado en < 2 s

### Pruebas para Historia de Usuario 1 ⚠️ ESCRIBIR PRIMERO — CONFIRMAR QUE FALLAN

> **NOTA: Escribir estas pruebas PRIMERO y confirmar que FALLAN antes de implementar (ciclo TDD Rojo)**

- [X] T020 [P] [US1] Crear archivo feature Cucumber en `backend/src/test/resources/features/marca/contenido_bienvenida.feature` con escenarios Gherkin (Dado/Cuando/Entonces): GET /v1/marca/contenido-bienvenida retorna 200 con logoUrl, videoUrl y version; retorna 503 cuando el servicio no está disponible
- [X] T021 [P] [US1] Crear step definitions Cucumber en `backend/src/test/java/com/resuelve/functional/marca/bdd/steps/ContenidoBienvenidaSteps.java` implementando los pasos Dado/Cuando/Entonces del feature file con REST-assured y @SpringBootTest; el paso "Entonces" DEBE incluir validación del cuerpo de respuesta contra el esquema OpenAPI usando `JsonSchemaValidator.matchesJsonSchemaInClasspath("contracts/openapi.yml")` para garantizar la conformidad del contrato (Principio IV)
- [X] T022 [P] [US1] Crear prueba unitaria backend en `backend/src/test/java/com/resuelve/unit/marca/ObtenerContenidoBienvenidaUCTest.java` verificando que el Caso de Uso delega a la interfaz de repositorio JPA y devuelve la entidad de dominio correctamente mapeada usando mock de repositorio
- [X] T023 [P] [US1] Crear prueba unitaria móvil `ObtenerContenidoBienvenidaUCTest` en `mobile/test/unit/aplicacion/obtener_contenido_bienvenida_uc_test.dart` verificando que el UC delega a `IContenidoMarcaRepositorio` y retorna `Result<ContenidoBienvenida>` con mock de Mockito
- [X] T024 [P] [US1] Crear prueba de integración móvil `ContenidoMarcaGatewayTest` en `mobile/test/integration/adaptadores/contenido_marca_gateway_test.dart` verificando mapeo DTO → entidad de dominio y manejo exitoso de respuesta HTTP 200 con servidor HTTP simulado (MockServer o mockito)
- [X] T025 [P] [US1] Crear prueba funcional BDD primer acceso con conexión en `mobile/test/functional/bdd/bienvenida_con_conexion_test.dart` con escenarios: logo visible al cargar, video se reproduce automáticamente, navegación al terminar video, navegación al tocar "Continuar"

> **⚠️ REMEDIACIÓN C2 — PRUEBA DE TIEMPO PARA CE-003**

- [X] T026 [P] [US1] Crear prueba funcional de tiempo en `mobile/test/functional/bdd/bienvenida_tiempo_logo_test.dart`: Escenario BDD — Dado que la APP arranca, Cuando la pantalla de bienvenida carga, Entonces el logo es visible en menos de 2000 ms; implementar con `Stopwatch` de Dart iniciado antes del pump del widget y aserción `expect(elapsed.inMilliseconds, lessThan(2000))` tras confirmar visibilidad del widget logo

### Implementación para Historia de Usuario 1

- [X] T027 [P] [US1] Crear interfaz de repositorio JPA backend `IContenidoBienvenidaRepositorio` en `backend/src/main/java/com/resuelve/dominio/marca/IContenidoBienvenidaRepositorio.java` con método `findByActivoTrue()` retornando `Optional<ContenidoBienvenidaJpaEntity>`
- [X] T028 [P] [US1] Crear entidad JPA `ContenidoBienvenidaJpaEntity` en `backend/src/main/java/com/resuelve/infraestructura/marca/ContenidoBienvenidaJpaEntity.java` con anotaciones @Entity, @Table(name="contenido_bienvenida"), @Id y campos mapeados a la tabla del esquema V1
- [X] T029 [P] [US1] Implementar repositorio JPA `ContenidoBienvenidaRepositorioJpa` en `backend/src/main/java/com/resuelve/infraestructura/marca/ContenidoBienvenidaRepositorioJpa.java` extendiendo JpaRepository y mapeando `ContenidoBienvenidaJpaEntity` → entidad de dominio `ContenidoBienvenida`
- [X] T030 [P] [US1] Implementar `ObtenerContenidoBienvenidaUC` backend en `backend/src/main/java/com/resuelve/aplicacion/marca/ObtenerContenidoBienvenidaUC.java` inyectando `IContenidoBienvenidaRepositorio`; retorna entidad de dominio o lanza excepción de negocio si no existe registro activo (depende T022 fallando)
- [X] T031 [P] [US1] Implementar `ContenidoBienvenidaMapper` en `backend/src/main/java/com/resuelve/adaptadores/marca/ContenidoBienvenidaMapper.java` mapeando entidad de dominio `ContenidoBienvenida` → DTO de respuesta `ContenidoBienvenidaResponse`
- [X] T032 [US1] Implementar `MarcaController` con endpoint `GET /v1/marca/contenido-bienvenida` en `backend/src/main/java/com/resuelve/adaptadores/marca/MarcaController.java`; respuesta 200 con DTO, 503 ante excepción de negocio (depende T020, T030, T031)
- [X] T033 [US1] Implementar `ObtenerContenidoBienvenidaUC` móvil en `mobile/lib/aplicacion/casos_de_uso/obtener_contenido_bienvenida_uc.dart` delegando a `IContenidoMarcaRepositorio` y envolviendo resultado en `Result<ContenidoBienvenida>` (depende T023 fallando)
- [X] T034 [US1] Implementar `ContenidoMarcaGateway` en `mobile/lib/adaptadores/gateways/contenido_marca_gateway.dart` usando cliente Dart generado para llamar GET /v1/marca/contenido-bienvenida y mapear `ContenidoBienvenidaResponse` → entidad de dominio (depende T024, T033)
- [X] T035 [US1] Implementar `BienvenidaPresenter` en `mobile/lib/adaptadores/presentadores/bienvenida_presenter.dart` orquestando `ObtenerContenidoBienvenidaUC` y `MarcarBienvenidaVistaUC`; emite estados: cargando, conContenido(videoUrl, logoUrl), sinVideo (depende T034)
- [X] T036 [US1] Implementar `BienvenidaScreen` en `mobile/lib/infraestructura/ui/pantallas/bienvenida_screen.dart` mostrando logo (visible siempre), reproductor video_player con auto-play, manejo de evento onVideoEnd para navegación automática y botón "Continuar" siempre visible (depende T025, T026, T035)

**Checkpoint**: Historia de Usuario 1 completamente funcional y verificable de forma independiente

---

## Fase 4: Historia de Usuario 2 — Primer Acceso sin Conexión (Prioridad: P2)

**Meta**: El cliente ve el logo y el botón "Continuar" sin conexión, sin mensajes de error (incluyendo errores de red y CDN), y puede navegar a la pantalla de cédula

**Prueba Independiente**: Activar modo avión antes de abrir APP; verificar logo visible ≤ 2 s, sin widget de error, botón "Continuar" habilitado y navega correctamente

### Pruebas para Historia de Usuario 2 ⚠️ ESCRIBIR PRIMERO — CONFIRMAR QUE FALLAN

> **NOTA: Escribir estas pruebas PRIMERO y confirmar que FALLAN antes de implementar (ciclo TDD Rojo)**

- [X] T037 [P] [US2] Crear prueba de integración `ContenidoMarcaGatewayOfflineTest` en `mobile/test/integration/adaptadores/contenido_marca_gateway_offline_test.dart` verificando que cuando `connectivity_plus` reporta `ConnectivityResult.none`, el gateway retorna `Result.failure` sin realizar llamada HTTP
- [X] T038 [P] [US2] Crear prueba funcional BDD sin conexión en `mobile/test/functional/bdd/bienvenida_sin_conexion_test.dart` con escenarios: logo siempre visible sin red, sin mensaje de error de video, botón "Continuar" habilitado, navegación funcional al tocar "Continuar"

> **⚠️ REMEDIACIÓN H2 — PRUEBAS DE CASOS LÍMITE DE RED Y CDN**

- [X] T039 [P] [US2] Crear prueba de integración `ContenidoMarcaGatewayTimeoutTest` en `mobile/test/integration/adaptadores/contenido_marca_gateway_timeout_test.dart`: verificar que cuando la petición HTTP excede el timeout configurado (simulando red interrumpida mid-stream con servidor que no responde), el gateway retorna `Result.failure(TimeoutException)` sin propagar excepción no controlada al llamante
- [X] T040 [P] [US2] Crear prueba de integración `ContenidoMarcaGatewayCdnErrorTest` en `mobile/test/integration/adaptadores/contenido_marca_gateway_cdn_error_test.dart`: verificar que cuando el servidor responde HTTP 404 o HTTP 500 (video no disponible en CDN), el gateway retorna `Result.failure` y el `BienvenidaPresenter` emite el estado `sinVideo` sin mostrar ningún mensaje de error al usuario

### Implementación para Historia de Usuario 2

- [X] T041 [US2] Agregar detección de conectividad con `connectivity_plus` a `ContenidoMarcaGateway` en `mobile/lib/adaptadores/gateways/contenido_marca_gateway.dart`: verificar `ConnectivityResult` antes de HTTP; si no hay red retornar `Result.failure(SinConectividadException())`; si hay timeout retornar `Result.failure(TimeoutException())`; si respuesta 4xx/5xx retornar `Result.failure(ErrorCdnException(statusCode))` (depende T037, T039, T040)
- [X] T042 [US2] Manejar todos los estados de fallo en `BienvenidaPresenter` en `mobile/lib/adaptadores/presentadores/bienvenida_presenter.dart`: para `SinConectividadException`, `TimeoutException` y `ErrorCdnException`, emitir estado `sinVideo` sin propagar ningún texto de error visible al usuario (depende T041, T038)
- [X] T043 [US2] Actualizar `BienvenidaScreen` en `mobile/lib/infraestructura/ui/pantallas/bienvenida_screen.dart` para que el estado `sinVideo` muestre únicamente logo + botón "Continuar" habilitado, sin ningún widget de error, spinner de red ni texto de fallo, independientemente del tipo de excepción subyacente (depende T042)

**Checkpoint**: Historias de Usuario 1 Y 2 completamente funcionales e independientes

---

## Fase 5: Acabado y Preocupaciones Transversales

**Propósito**: Flujo completo de arranque, cobertura de calidad y entregables finales

- [X] T044 [P] Crear prueba funcional BDD segundo acceso en `mobile/test/functional/bdd/segundo_acceso_test.dart` verificando que cuando el flag `primer_uso_completado` es true, la APP omite la pantalla de bienvenida y navega directamente al flujo de autenticación/cédula
- [X] T045 Implementar `ArranqueScreen` (pantalla inicial) en `mobile/lib/infraestructura/ui/pantallas/arranque_screen.dart`: llama `VerificarPrimerUsoUC` → si retorna true navega a `BienvenidaScreen`, si retorna false navega a `PantallaCedula` (depende T044)
- [X] T046 [P] Ejecutar suite completa backend (`./gradlew test jacocoTestReport`) y verificar que la cobertura JaCoCo por clase y global es ≥ 80% revisando `backend/build/reports/jacoco/test/html/index.html`; confirmar en los logs que las migraciones Flyway V1 y R__ se aplicaron sin errores
- [X] T047 [P] Ejecutar suite completa móvil (`flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`) y verificar cobertura lcov por clase y global ≥ 80% revisando `mobile/coverage/html/index.html`
- [X] T048 [P] Revisar y corregir clases identificadas con cobertura < 80% en T046 y T047 añadiendo pruebas unitarias o de integración faltantes en los directorios `test/unit/` correspondientes
- [X] T049 [P] Actualizar `quickstart.md` con los comandos definitivos de ejecución verificados durante la implementación y añadir sección de troubleshooting para errores comunes de Flyway y H2

---

## Dependencias y Orden de Ejecución

### Dependencias entre Fases

- **Setup (Fase 1)**: Sin dependencias — puede comenzar inmediatamente
- **Fundamentos (Fase 2)**: Depende de Setup completo — BLOQUEA todas las historias de usuario
- **Historia de Usuario 1 (Fase 3)**: Depende de Fundamentos completos
- **Historia de Usuario 2 (Fase 4)**: Depende de Fundamentos completos; puede iniciarse en paralelo con US1
- **Acabado (Fase 5)**: Depende de US1 y US2 completos

### Dependencias Internas: Fase 2 (Fundamentos)

```
T007 (generar cliente Dart — primero)
    ↓
T008–T013 (en paralelo: migraciones, entidades, interfaces)
    ↓
T014, T015, T016 (pruebas unitarias/integración — en paralelo → DEBEN fallar)
    ↓
T017 (VerificarPrimerUsoUC + MarcarBienvenidaVistaUC — depende T014, T015)
T018 (PrimerUsoSharedPrefs + PrimerUsoGateway — depende T016)
    ↓
T019 (inyección de dependencias — al final de Fundamentos)
```

### Dependencias Internas: Fase 3 (US1)

```
T020–T026 (pruebas — en paralelo → DEBEN fallar)
    ↓
T027, T028, T029, T031, T033 (en paralelo)
    ↓
T030 (ObtenerContenidoBienvenidaUC backend — depende T022)
T034 (ContenidoMarcaGateway móvil — depende T024, T033)
T032 (MarcaController — depende T020, T030, T031)
    ↓
T035 (BienvenidaPresenter — depende T034)
    ↓
T036 (BienvenidaScreen — depende T025, T026, T035)
```

### Dependencias Internas: Fase 4 (US2)

```
T037, T038, T039, T040 (pruebas — en paralelo → DEBEN fallar)
    ↓
T041 (gateway offline + timeout + CDN — depende T037, T039, T040)
    ↓
T042 (presenter todos los fallos — depende T041, T038)
    ↓
T043 (screen estado sinVideo — depende T042)
```

### Oportunidades Paralelas

- Toda la Fase 1 marcada [P] puede ejecutarse en paralelo entre sí
- En Fase 2, T008–T016 pueden ejecutarse en paralelo (T007 debe completarse primero)
- Una vez completa Fase 2, US1 y US2 pueden iniciarse en paralelo por distintos desarrolladores
- Backend (T020-T022, T027-T032) y Móvil (T023-T026, T033-T036) de US1 pueden desarrollarse en paralelo
- Las 4 pruebas de US2 (T037-T040) pueden escribirse en paralelo

---

## Ejemplo de Paralelismo: Fase 2 (Fundamentos)

```bash
# Paso 1: Completar T007 (prerequisito)
Tarea: "Generar cliente Dart con openapi-generator-cli"

# Paso 2: Lanzar en paralelo (tras T007):
Tarea: "Flyway V1__crear_tabla en backend/src/main/resources/db/migration/"
Tarea: "Flyway R__seed en backend/src/main/resources/db/data/"
Tarea: "Test data SQL en backend/src/test/resources/db/test-data/"
Tarea: "Entidad ContenidoBienvenida backend en dominio/marca/"
Tarea: "Entidades dominio móvil en mobile/lib/dominio/entidades/"
Tarea: "Interfaces repositorio en mobile/lib/dominio/repositorios/"

# Paso 3: Pruebas (confirmar que FALLAN) — en paralelo:
Tarea: "VerificarPrimerUsoUCTest en mobile/test/unit/aplicacion/"   ← C1
Tarea: "MarcarBienvenidaVistaUCTest en mobile/test/unit/aplicacion/"  ← C1
Tarea: "PrimerUsoGatewayTest en mobile/test/integration/adaptadores/"  ← H1
```

---

## Estrategia de Implementación

### MVP Primero (Solo Historia de Usuario 1)

1. Completar Fase 1: Setup (6 tareas)
2. Completar Fase 2: Fundamentos (13 tareas — CRÍTICO, incluye pruebas C1+H1)
3. Completar Fase 3: Historia de Usuario 1 (17 tareas, incluye prueba de tiempo C2)
4. **PARAR Y VALIDAR**: `./gradlew test` + `flutter test integration_test/funcional/`
5. Revisar cobertura: `./gradlew jacocoTestReport` + `flutter test --coverage`

### Entrega Incremental

1. Setup + Fundamentos → Base lista (BD con Flyway, UCs de primer uso con pruebas)
2. US1 completo → Verificar independientemente → Demostrar (¡MVP!)
3. US2 completo → Verificar independientemente (incluyendo casos límite H2)
4. Acabado → Cobertura completa ≥ 80% → Entrega final

---

## Notas

- [P] = archivos distintos, sin dependencias pendientes en la misma fase
- Las etiquetas [US1]/[US2] mapean cada tarea a su historia de usuario para trazabilidad
- Las pruebas BDD son OBLIGATORIAS (Principio II de la Constitución) — no son opcionales
- Las pruebas DEBEN fallar antes de iniciar la implementación (ciclo TDD Rojo-Verde)
- El código en `mobile/lib/infraestructura/red/generated/` es generado — NO modificar manualmente
- Los archivos en `backend/src/main/resources/db/migration/` siguen convención Flyway: `V{n}__{descripcion}.sql`
- Los archivos en `backend/src/main/resources/db/data/` son migraciones repetibles Flyway: `R__{descripcion}.sql`
- La sentencia SQL en `R__seed_contenido_marca.sql` usa `INSERT ... ON CONFLICT (id) DO UPDATE` para compatibilidad PostgreSQL + H2 (MODE=PostgreSQL)
- Confirmar cobertura ≥ 80% por clase y global antes de cualquier merge (Principio V)
- Hacer commit tras cada tarea o grupo lógico completado
- Detenerse en cada checkpoint para validar la historia de forma independiente

