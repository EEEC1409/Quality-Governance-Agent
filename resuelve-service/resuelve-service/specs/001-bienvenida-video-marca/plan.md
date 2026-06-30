# Plan de Implementación: Pantalla de Bienvenida con Video de Marca

**Rama**: `001-bienvenida-video-marca` | **Fecha**: 2026-06-27 | **Spec**: [spec.md](spec.md)

**Entrada**: Especificación de funcionalidad en `specs/001-bienvenida-video-marca/spec.md`

## Resumen

Implementar la pantalla de bienvenida de la aplicación móvil Resuelve que muestra el logo de
la marca y reproduce automáticamente el video corporativo en el primer arranque. El backend
(`resuelve-service`) expone un endpoint OpenAPI que entrega las URLs del logo y el video. La APP
móvil (Flutter) consume ese endpoint, maneja la conectividad offline de forma elegante y navega
a la pantalla de ingreso de cédula al finalizar el video o al pulsar "Continuar".

## Contexto Técnico

**Lenguaje/Versión**:
- Backend: Java 17 (LTS) + Spring Boot 3.x
- Móvil: Dart 3.x + Flutter 3.x

**Dependencias Principales**:
- Backend: Spring Web, Spring Validation, springdoc-openapi 2.x, Spring Data JPA, Flyway Core, PostgreSQL Driver, H2 (scope test)
- Móvil: video_player ^2.x, connectivity_plus ^6.x, dio ^5.x (cliente HTTP generado por openapi-generator)

**Almacenamiento**:
- Backend: PostgreSQL (producción/staging) · H2 in-memory (tests) — gestionado con Flyway para migraciones y datos precargados
- Móvil: shared_preferences ^2.x — persiste el flag `primer_uso_completado`

**Pruebas**:
- Backend: JUnit 5 + Cucumber 7 (BDD), MockMvc, JaCoCo (cobertura)
- Móvil: flutter_test + bdd_widget_test, integration_test package, lcov (cobertura)

**Plataforma Destino**: iOS 14+ y Android 8.0+ (API 26+), distribuida como aplicación nativa vía Flutter

**Tipo de Proyecto**: Aplicación móvil (Flutter) + API REST backend (Spring Boot) — monorepo

**Objetivos de Rendimiento**:
- Logo visible en ≤ 2 s desde el arranque de la APP (CE-003)
- Endpoint backend: respuesta ≤ 500 ms en p95 bajo carga normal

**Restricciones**:
- Offline-capable: logo y botón "Continuar" DEBEN funcionar sin red
- Sin mensajes de error visibles al usuario cuando el video no está disponible
- El video no bloquea la navegación

**Escala/Alcance**: Pantalla de primer arranque; afecta al 100% de instalaciones nuevas

## Verificación de Constitución

*GATE: Debe pasar antes de la investigación Phase 0. Re-verificar tras el diseño Phase 1.*

| Principio | Estado | Evidencia / Justificación |
|-----------|--------|--------------------------|
| **I. Arquitectura Limpia** | ✅ PASA | Estructura de capas definida: `dominio/`, `aplicacion/`, `adaptadores/`, `infraestructura/` en ambos proyectos. La regla de dependencia se cumple: UI y HTTP client en infraestructura, lógica de negocio en dominio/aplicacion. |
| **II. Pruebas BDD** | ✅ PASA | Tres niveles obligatorios: unitarias (lógica de Casos de Uso), integración (Caso de Uso + Gateway), funcionales (flujo completo desde UI hasta API). Escenarios Dado/Cuando/Entonces definidos en spec.md. |
| **III. SOLID / YAGNI / DRY** | ✅ PASA | Un Caso de Uso por responsabilidad. No se implementan pantallas adicionales ni abstracciones innecesarias. Entidades reutilizadas en todos los Casos de Uso de bienvenida. |
| **IV. API-First con OpenAPI** | ✅ PASA | Contrato OpenAPI 3.0 definido en `contracts/openapi.yml` antes de cualquier implementación. Cliente Dart generado con openapi-generator-cli. |
| **V. Métricas y Cobertura** | ✅ PASA | JaCoCo (backend) y lcov (móvil) configurados con umbral ≥ 80% por clase y global. Reportes JUnit XML publicados en CI. |

**Resultado del GATE**: ✅ Sin violaciones — se puede proceder a la implementación.

## Estructura del Proyecto

### Documentación (esta funcionalidad)

```text
specs/001-bienvenida-video-marca/
├── plan.md              # Este archivo (/speckit-plan)
├── research.md          # Decisiones técnicas Phase 0 (/speckit-plan)
├── data-model.md        # Modelo de datos Phase 1 (/speckit-plan)
├── quickstart.md        # Guía de validación Phase 1 (/speckit-plan)
├── contracts/
│   └── openapi.yml      # Contrato OpenAPI 3.0 Phase 1 (/speckit-plan)
├── checklists/
│   └── requirements.md  # Checklist de calidad (/speckit-specify)
└── tasks.md             # Tareas de implementación (/speckit-tasks — NO creado aquí)
```

### Código Fuente (raíz del repositorio)

```text
backend/                              # Spring Boot — resuelve-service API
├── src/
│   ├── main/
│   │   ├── java/com/resuelve/
│   │   │   ├── dominio/
│   │   │   │   └── marca/
│   │   │   │       └── ContenidoBienvenida.java        # Entidad
│   │   │   ├── aplicacion/
│   │   │   │   └── marca/
│   │   │   │       └── ObtenerContenidoBienvenidaUC.java  # Caso de Uso
│   │   │   ├── adaptadores/
│   │   │   │   └── marca/
│   │   │   │       ├── MarcaController.java            # Adaptador entrada (HTTP)
│   │   │   │       └── ContenidoBienvenidaMapper.java  # Mapeador DTO ↔ Entidad
│   │   │   └── infraestructura/
│   │   │       └── marca/
│   │   │           └── ContenidoBienvenidaRepositorioJpa.java  # Impl. repositorio JPA
│   │   └── resources/
│   │       ├── application.yml                    # Config producción (datasource PostgreSQL)
│   │       ├── application-local.yml              # Config desarrollo local (H2 o PostgreSQL local)
│   │       └── db/
│   │           ├── migration/
│   │           │   └── V1__crear_tabla_contenido_marca.sql   # Esquema inicial (Flyway)
│   │           └── data/
│   │               └── R__seed_contenido_marca.sql           # Datos precargados (Flyway repeatable)
│   └── test/
│       ├── java/com/resuelve/
│       │   ├── unit/marca/
│       │   ├── integration/marca/
│       │   └── functional/marca/
│       │       └── bdd/
│       │           └── steps/
│       └── resources/
│           ├── application-test.yml               # Config pruebas (H2 in-memory, Flyway habilitado)
│           ├── features/
│           │   └── marca/
│           │       └── contenido_bienvenida.feature   # Escenarios Gherkin BDD
│           └── db/
│               └── test-data/
│                   └── contenido_marca_test_data.sql  # Datos de prueba adicionales (si aplica)
└── build.gradle

mobile/                               # Flutter — aplicación móvil Resuelve
├── lib/
│   ├── dominio/
│   │   ├── entidades/
│   │   │   └── contenido_bienvenida.dart
│   │   └── repositorios/
│   │       ├── i_contenido_marca_repositorio.dart
│   │       └── i_primer_uso_repositorio.dart
│   ├── aplicacion/
│   │   └── casos_de_uso/
│   │       ├── obtener_contenido_bienvenida_uc.dart
│   │       ├── verificar_primer_uso_uc.dart
│   │       └── marcar_bienvenida_vista_uc.dart
│   ├── adaptadores/
│   │   ├── presentadores/
│   │   │   └── bienvenida_presenter.dart
│   │   └── gateways/
│   │       ├── contenido_marca_gateway.dart
│   │       └── primer_uso_gateway.dart
│   └── infraestructura/
│       ├── ui/
│       │   └── pantallas/
│       │       └── bienvenida_screen.dart
│       ├── red/
│       │   └── marca_api_client.dart              # Generado por openapi-generator
│       └── persistencia/
│           └── primer_uso_shared_prefs.dart
└── test/
    ├── unit/
    ├── integration/
    └── functional/
        └── bdd/
```

**Decisión de Estructura**: Opción monorepo con dos sub-proyectos (`backend/` y `mobile/`). El backend Spring Boot expone la API RESTful definida en OpenAPI 3.0. El cliente Dart se genera automáticamente desde el contrato. La APP móvil Flutter implementa Arquitectura Limpia con las cuatro capas en paquetes separados.

## Mapeo de Terminología

Tabla de referencia para alinear el lenguaje de negocio de `spec.md` con los nombres técnicos
usados en `tasks.md` y en el código fuente.

| Nombre de Negocio (spec.md) | Nombre Técnico (clase/archivo) | Capa |
|-----------------------------|-------------------------------|------|
| Pantalla de bienvenida | `BienvenidaScreen` | Infraestructura — móvil |
| Pantalla de arranque | `ArranqueScreen` | Infraestructura — móvil |
| Pantalla de cédula / Pantalla de ingreso de cédula | `PantallaCedula` | Infraestructura — móvil (fuera del alcance de US-01) |
| Primer acceso / Primer uso | `VerificarPrimerUsoUC`, `MarcarBienvenidaVistaUC`, `EstadoPrimerUso` | Aplicación + Dominio — móvil |
| Contenido de bienvenida (logo + video) | `ContenidoBienvenida` | Dominio — móvil y backend |
| Gateway de marca / cliente de marca | `ContenidoMarcaGateway` | Adaptadores — móvil |
| Estado de primer uso (persistencia) | `PrimerUsoGateway`, `PrimerUsoSharedPrefs` | Adaptadores + Infraestructura — móvil |
| Registro activo en BD (backend) | `ContenidoBienvenidaJpaEntity` (activo=TRUE) | Infraestructura — backend |

## Seguimiento de Complejidad

> No hay violaciones a la Constitución en esta funcionalidad.
