<!--
SYNC IMPACT REPORT
==================
Cambio de versión: 1.1.0 → 1.2.0 (MINOR — contexto móvil añadido a Estándares Tecnológicos;
  Principio II expandido con pruebas de comportamiento móvil y escenarios offline;
  derivado de la historia de usuario US-01 · EPIC-01)

Principios modificados:
  - II. Estrategia de Pruebas BDD — ampliado para incluir pruebas de comportamiento
    de aplicación móvil y escenarios de conectividad offline (dado US-01 criterio 3)

Secciones modificadas:
  - Estándares Tecnológicos — especificado que el proyecto es una aplicación móvil;
    añadidos estándares de plataforma móvil y herramientas de prueba UI

Secciones añadidas:
  - Ninguna

Secciones eliminadas:
  - Ninguna

Estado de propagación de plantillas:
  ✅ .specify/templates/plan-template.md — Constitution Check genérico; sin cambios requeridos
  ✅ .specify/templates/spec-template.md — formato Dado/Cuando/Entonces ya alineado con Principio II
  ✅ .specify/templates/tasks-template.md — estructura de fases compatible; sin cambios requeridos

TODOs pendientes:
  - Ninguno.
-->

# Constitución de la Aplicación Móvil resuelve-service

## Principios Fundamentales

### I. Arquitectura Limpia (NO NEGOCIABLE)

El proyecto DEBE seguir la Arquitectura Limpia definida por Robert C. Martin.

- El código DEBE organizarse en cuatro capas concéntricas: **Entidades**, **Casos de Uso**,
  **Adaptadores de Interfaz** y **Frameworks & Controladores**.
- La **Regla de Dependencia** es absoluta: las dependencias del código fuente DEBEN apuntar
  únicamente hacia adentro. Las capas externas dependen de las internas; las capas internas
  NO DEBEN referenciar capas externas.
- Las **Entidades** encapsulan las reglas de negocio empresariales y DEBEN ser independientes
  de cualquier framework.
- Los **Casos de Uso** encapsulan las reglas de negocio específicas de la aplicación. NO DEBEN
  depender de frameworks, bases de datos ni de la interfaz de usuario.
- Los **Adaptadores de Interfaz** (controladores, presentadores, gateways) traducen datos entre
  los casos de uso y los formatos externos. NO DEBEN contener lógica de negocio.
- Los **Frameworks & Controladores** (frameworks móvil, ORMs, APIs externas, servicios de red)
  están confinados a la capa más externa. Reemplazarlos NO DEBE requerir cambios en las capas
  internas.
- Toda comunicación entre capas DEBE realizarse a través de interfaces definidas (puertos);
  las implementaciones concretas se inyectan mediante Inversión de Dependencias.

**Justificación**: Aplicar la regla de dependencia hace que el sistema sea independientemente
testeable, desplegable y mantenible. La lógica de negocio sobrevive a los cambios tecnológicos
y de plataforma móvil.

### II. Estrategia de Pruebas BDD (NO NEGOCIABLE)

Todas las pruebas DEBEN escribirse siguiendo las convenciones de Desarrollo Guiado por Comportamiento (BDD).

- Los escenarios de prueba DEBEN expresarse en formato Dado/Cuando/Entonces
  (compatible con Gherkin donde las herramientas lo soporten).
- Tres niveles de prueba son OBLIGATORIOS para cada funcionalidad:
  - **Pruebas unitarias**: validan clases o funciones individuales en aislamiento; DEBEN cubrir
    todas las reglas de negocio en las capas de Entidades y Casos de Uso.
  - **Pruebas de integración**: validan la colaboración entre capas (por ejemplo, Caso de Uso +
    Gateway), usando dobles de prueba reales o en proceso en los límites.
  - **Pruebas funcionales**: validan los flujos de usuario de extremo a extremo, ejercitando el
    stack completo desde la interacción en pantalla hasta la API y la persistencia.
- Las pruebas DEBEN escribirse **antes** que la implementación (ciclo TDD: Rojo-Verde-Refactorización).
- Los archivos de prueba DEBEN organizarse reflejando la estructura del código fuente:
  `tests/unit/`, `tests/integration/`, `tests/functional/`.
- Cada escenario de aceptación definido en `spec.md` DEBE corresponderse con al menos una prueba
  funcional con una declaración Dado/Cuando/Entonces trazable.
- **Escenarios de conectividad offline**: toda pantalla o flujo que pueda ejecutarse sin conexión
  a internet DEBE tener al menos un escenario BDD explícito que cubra el comportamiento offline.
  El sistema DEBE degradar de forma elegante: mostrar siempre los elementos estáticos disponibles
  y habilitar la navegación mínima requerida aun sin red.
- **Pruebas de comportamiento móvil**: los flujos que dependen de eventos nativos del dispositivo
  (reproducción de video, gestos, estados de ciclo de vida de la pantalla) DEBEN cubrirse con
  pruebas funcionales que simulen o instrumenten dichos eventos.

**Justificación**: BDD cierra la brecha entre especificación y verificación. Cubrir escenarios
offline garantiza que la APP funcione en condiciones reales de uso móvil; los escenarios de
comportamiento nativo previenen regresiones silenciosas en interacciones dependientes del dispositivo.

### III. Buenas Prácticas de Programación (NO NEGOCIABLE)

Todo el código DEBE adherirse a los principios SOLID, YAGNI y DRY.

**SOLID**:
- **S** — Responsabilidad Única: cada clase o módulo DEBE tener exactamente una razón para cambiar.
- **O** — Abierto/Cerrado: las clases DEBEN estar abiertas para extensión y cerradas para modificación.
- **L** — Sustitución de Liskov: los subtipos DEBEN ser sustituibles por sus tipos base sin alterar
  la corrección del programa.
- **I** — Segregación de Interfaces: las interfaces DEBEN ser específicas; los clientes NO DEBEN
  verse forzados a depender de métodos que no utilizan.
- **D** — Inversión de Dependencias: los módulos de alto nivel NO DEBEN depender de módulos de bajo
  nivel; ambos DEBEN depender de abstracciones.

**YAGNI** (No Lo Vas a Necesitar):
- NO DEBE escribirse código para requisitos futuros hipotéticos.
- Las abstracciones se justifican únicamente cuando existe o está planeado inmediatamente
  un segundo caso de uso concreto.

**DRY** (No Te Repitas):
- Cada pieza de conocimiento DEBE tener una representación única, inequívoca y autorizada.
- La duplicación de lógica (no la similitud estructural accidental) DEBE extraerse en una
  abstracción compartida antes de integrar el código.

**Justificación**: Estos principios previenen la acumulación de deuda técnica, mantienen el
código legible y apoyan directamente la testeabilidad requerida por la Arquitectura Limpia.

### IV. API-First con OpenAPI (NO NEGOCIABLE)

Toda API DEBE diseñarse y documentarse antes de comenzar la implementación.

- El contrato de la API DEBE definirse en un archivo de especificación **OpenAPI 3.x**
  (`openapi.yml` u `openapi.json`) ubicado en `specs/[###-nombre-funcionalidad]/contracts/`.
- La especificación OpenAPI es la **única fuente de verdad**; los stubs del servidor, los SDKs
  de cliente y los modelos de validación DEBEN generarse a partir de ella usando **openapi-generator**.
- Ningún endpoint de API DEBE implementarse sin una definición OpenAPI correspondiente y revisada.
  Las desviaciones manuales del contrato generado están prohibidas.
- La especificación DEBE incluir: rutas, métodos HTTP, esquemas de solicitud/respuesta,
  respuestas de error (4xx/5xx) y definiciones de seguridad.
- Los cambios que rompan un contrato existente DEBEN provocar un incremento de versión MAJOR en la
  API y la actualización del archivo OpenAPI antes de cualquier cambio de código.
- Las pruebas funcionales (Principio II) DEBEN validar las respuestas contra el esquema OpenAPI
  usando una librería de validación de esquemas.

**Justificación**: API-First garantiza que el diseño esté orientado a las necesidades del
consumidor, habilita el desarrollo paralelo de la aplicación móvil y el backend, y asegura
la consistencia del contrato mediante herramientas automatizadas.

### V. Métricas de Calidad y Cobertura (NO NEGOCIABLE)

Cada build DEBE satisfacer las siguientes métricas antes de que se permita la integración.

- **Cobertura por clase**: cada clase DEBE alcanzar una cobertura de líneas/ramas **≥ 80%**.
  Las clases por debajo de este umbral NO DEBEN integrarse.
- **Cobertura global**: el agregado del proyecto DEBE mantener una cobertura **≥ 80%**.
  Una regresión por debajo de este umbral es un fallo de build.
- Los reportes de pruebas DEBEN generarse en cada ejecución de CI en un formato legible por
  máquina estándar (por ejemplo, JUnit XML, Cobertura XML o lcov) y publicarse como artefactos
  del build.
- Los reportes de cobertura en formato HTML DEBEN generarse y enlazarse en el resumen del
  pull request.
- Las exclusiones de la medición de cobertura (por ejemplo, código generado, DTOs sin lógica,
  clases de enlace de plataforma móvil) DEBEN declararse explícitamente en el archivo de
  configuración de cobertura y revisarse durante el proceso de pull request.

**Justificación**: Los umbrales cuantitativos previenen la degradación silenciosa de la calidad
de las pruebas. Requerir cobertura por clase garantiza que ningún componente individual quede
sin probar, incluso si el promedio global se mantiene saludable.

## Estándares Tecnológicos

Esta sección recoge las decisiones tecnológicas no negociables que soportan los Principios Fundamentales.

**Tipo de proyecto**: aplicación móvil cliente-final (iOS y/o Android) con backend de servicios REST.
El cliente móvil consume exclusivamente APIs definidas por contrato OpenAPI (Principio IV).

- **Estructura de la arquitectura**: las capas DEBEN corresponder a paquetes o módulos separados:
  `dominio` (Entidades), `aplicacion` (Casos de Uso), `adaptadores` (Adaptadores de Interfaz),
  `infraestructura` (Frameworks & Controladores — framework móvil, cliente HTTP, persistencia local).
- **Plataforma móvil**: la elección de framework móvil (por ejemplo, Flutter, React Native, Swift/UIKit,
  Kotlin/Jetpack) DEBE declararse en `plan.md` y mantenerse consistente en todo el proyecto.
  La lógica de negocio NO DEBE acoplarse al framework de UI elegido.
- **Generación de API**: DEBE usarse `openapi-generator-cli`; la configuración del generador
  (`openapitools.json` o equivalente) DEBE estar bajo control de versiones. Los clientes de red
  en la APP DEBEN generarse a partir del contrato OpenAPI.
- **Framework de pruebas**: cualquier framework compatible con BDD y con la plataforma elegida
  (por ejemplo, JUnit 5 + Cucumber para Android, XCTest + Quick/Nimble para iOS, Flutter Test
  con BDD-style para Flutter) es aceptable; la elección DEBE declararse en `plan.md`.
- **Herramienta de cobertura**: una herramienta compatible con la plataforma (por ejemplo, JaCoCo
  para Android, Xcode Coverage para iOS, flutter_coverage para Flutter) DEBE configurarse y sus
  umbrales DEBEN verificarse en CI.
- **Manejo de conectividad**: la APP DEBE detectar el estado de red y exponer dicho estado como
  una abstracción en la capa de Adaptadores de Interfaz; los Casos de Uso NO DEBEN consultar
  directamente el estado de red del sistema operativo.

## Flujo de Desarrollo

Estándares que gobiernan cómo el trabajo avanza desde la idea hasta la producción.

- Cada funcionalidad DEBE comenzar con una ejecución de `/speckit-specify` para capturar los
  escenarios de aceptación BDD (incluyendo escenarios offline cuando aplique) antes de planificar
  o codificar.
- El contrato OpenAPI DEBE redactarse y confirmarse como parte de la fase de planificación
  (`/speckit-plan`) antes de crear las tareas de implementación.
- Las pruebas DEBEN escribirse y confirmarse como fallidas antes de iniciar cualquier tarea de
  implementación (fase Rojo). La fase Verde solo comienza tras la aprobación de la prueba fallida.
- Todos los pull requests DEBEN pasar las métricas de cobertura definidas en el Principio V.
  El pipeline de CI las aplica automáticamente; las anulaciones manuales no están permitidas.
- El cumplimiento de la arquitectura (regla de dependencia del Principio I) DEBE verificarse
  usando una herramienta de análisis estático (por ejemplo, ArchUnit, dependency-cruiser,
  lint-rules personalizadas) como parte del pipeline de CI.
- La sección de Verificación de Constitución en `plan.md` DEBE referenciar explícitamente cada
  uno de los cinco Principios Fundamentales y documentar cualquier desviación justificada antes
  de que comience la investigación de la fase 0.

## Gobernanza

Esta constitución reemplaza todas las demás prácticas de desarrollo, directrices y convenciones
del equipo dentro del proyecto `resuelve-service`. En caso de conflicto, la constitución tiene
precedencia.

**Procedimiento de enmienda**:
1. Proponer la enmienda en un pull request que modifique `.specify/memory/constitution.md`.
2. Incrementar la versión según las reglas de versionado semántico documentadas a continuación.
3. Actualizar todas las plantillas y documentos dependientes según se describe en el Reporte de
   Impacto de Sincronización producido por `/speckit-constitution`.
4. Obtener al menos una revisión y aprobación de un par antes de integrar.

**Política de versionado**:
- MAJOR: eliminación o redefinición de un principio existente; cambio de gobernanza incompatible
  con versiones anteriores.
- MINOR: nuevo principio o sección añadida; expansión material de la guía existente.
- PATCH: aclaraciones, mejoras de redacción, correcciones tipográficas, refinamientos no semánticos.

**Revisión de cumplimiento**:
- Cada pull request DEBE incluir una sección de Verificación de Constitución en su `plan.md`
  confirmando la adhesión a los cinco Principios Fundamentales.
- El seguimiento de complejidad en `plan.md` DEBE documentar cualquier desviación con justificación.
- Se RECOMIENDA una revisión trimestral de esta constitución para reflejar la evolución del proyecto.

**Versión**: 1.2.0 | **Ratificada**: 2026-06-27 | **Última Enmienda**: 2026-06-27
