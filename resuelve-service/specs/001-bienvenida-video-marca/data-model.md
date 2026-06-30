# Modelo de Datos: Pantalla de Bienvenida con Video de Marca

**Fecha**: 2026-06-27
**Funcionalidad**: US-01 · EPIC-01

---

## Entidades del Dominio

### ContenidoBienvenida

Representa los recursos de marca que la pantalla de bienvenida necesita mostrar.
Esta entidad pertenece a la capa de **Dominio** y es independiente de cualquier framework.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `logoUrl` | `String` (URI) | Sí | URL absoluta del logo de Resuelve. El logo es el recurso principal; siempre debe estar disponible. |
| `videoUrl` | `String` (URI) | Sí | URL absoluta del video de marca. Su ausencia o fallo de carga no bloquea el flujo. |
| `version` | `String` | Sí | Versión del contenido (formato semver o fecha). Permite al cliente caché invalidar cuando cambia el contenido. |

**Reglas de validación**:
- `logoUrl` DEBE ser una URI válida con esquema `https`.
- `videoUrl` DEBE ser una URI válida con esquema `https`.
- `version` NO DEBE ser vacío.

**Reglas de negocio**:
- Si `videoUrl` no es alcanzable o la red no está disponible, la entidad sigue siendo válida;
  la capa de Aplicación decide cómo renderizarla.
- La entidad NO contiene lógica de reproducción ni de UI; esa responsabilidad pertenece a la
  capa de Infraestructura.

---

### EstadoPrimerUso

Representa el estado del dispositivo respecto al primer acceso del cliente.
Esta entidad pertenece a la capa de **Dominio** y persiste en el dispositivo.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `bienvenidaVista` | `Boolean` | Sí | `true` si el cliente ya completó la pantalla de bienvenida y avanzó a la pantalla de cédula; `false` en caso contrario. |

**Reglas de negocio**:
- `bienvenidaVista` se establece en `true` únicamente cuando el cliente llega exitosamente a la
  pantalla de ingreso de cédula (no antes).
- Si el cliente cierra la APP antes de llegar a la pantalla de cédula, `bienvenidaVista` permanece
  en `false` y la pantalla de bienvenida se vuelve a mostrar en el próximo arranque.

---

## Interfaces de Repositorio (puertos de dominio)

### IContenidoMarcaRepositorio

Interfaz en la capa de **Dominio** que abstrae el origen del contenido de bienvenida.

```
IContenidoMarcaRepositorio
  + obtener(): Future<Result<ContenidoBienvenida>>
```

- Implementación concreta (`ContenidoMarcaGateway`) en la capa de **Adaptadores de Interfaz**.
- El transporte HTTP se encuentra en la capa de **Infraestructura** (cliente generado por openapi-generator).
- `Result<T>` es un tipo algebraico (`Success<T>` | `Failure`) que evita excepciones no controladas.

### IPrimerUsoRepositorio

Interfaz en la capa de **Dominio** que abstrae la persistencia del estado de primer uso.

```
IPrimerUsoRepositorio
  + obtenerEstado(): Future<EstadoPrimerUso>
  + marcarComoVisto(): Future<void>
```

- Implementación concreta (`PrimerUsoSharedPrefs`) en la capa de **Infraestructura**.

---

## Casos de Uso (capa de Aplicación)

### ObtenerContenidoBienvenidaUC

| Entrada | Sin parámetros |
|---------|----------------|
| Salida | `Future<Result<ContenidoBienvenida>>` |
| Dependencia | `IContenidoMarcaRepositorio` |

Orquesta la obtención del contenido de bienvenida. Si el repositorio devuelve `Failure`
(red no disponible, error de servidor), el Caso de Uso retorna `Failure` sin lanzar excepción.

### VerificarPrimerUsoUC

| Entrada | Sin parámetros |
|---------|----------------|
| Salida | `Future<bool>` — `true` si la bienvenida NO ha sido vista aún |
| Dependencia | `IPrimerUsoRepositorio` |

Determina si la pantalla de bienvenida debe mostrarse. Es el primer Caso de Uso que ejecuta
el flujo de arranque de la APP.

### MarcarBienvenidaVistaUC

| Entrada | Sin parámetros |
|---------|----------------|
| Salida | `Future<void>` |
| Dependencia | `IPrimerUsoRepositorio` |

Persiste `bienvenidaVista = true` al momento en que el usuario llega a la pantalla de cédula.

---

## Esquema de Base de Datos (capa de Infraestructura — Backend)

### Migración V1: Esquema inicial

Archivo: `backend/src/main/resources/db/migration/V1__crear_tabla_contenido_marca.sql`

```sql
-- Tabla para almacenar el contenido de la pantalla de bienvenida de la marca Resuelve.
-- Permite actualizar logo y video sin redespliegue de la aplicación.
CREATE TABLE contenido_bienvenida (
    id          BIGINT          NOT NULL,
    logo_url    VARCHAR(500)    NOT NULL,
    video_url   VARCHAR(500)    NOT NULL,
    version     VARCHAR(50)     NOT NULL,
    activo      BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_contenido_bienvenida PRIMARY KEY (id),
    CONSTRAINT ck_logo_url_https  CHECK (logo_url  LIKE 'https://%'),
    CONSTRAINT ck_video_url_https CHECK (video_url LIKE 'https://%')
);

COMMENT ON TABLE  contenido_bienvenida           IS 'Contenido de marca para la pantalla de bienvenida de la APP Resuelve';
COMMENT ON COLUMN contenido_bienvenida.logo_url  IS 'URL HTTPS del logo principal de Resuelve';
COMMENT ON COLUMN contenido_bienvenida.video_url IS 'URL HTTPS del video de presentación de la marca';
COMMENT ON COLUMN contenido_bienvenida.version   IS 'Versión del contenido; permite invalidar caché en el cliente';
COMMENT ON COLUMN contenido_bienvenida.activo    IS 'Solo el registro con activo=TRUE se retorna al cliente';
```

### Migración R: Datos precargados (seed)

Archivo: `backend/src/main/resources/db/data/R__seed_contenido_marca.sql`

```sql
-- Datos iniciales del contenido de bienvenida.
-- Migración repetible: se re-ejecuta cuando cambia el checksum del archivo.
-- Actualizar este archivo para cambiar la URL del video o logo sin redespliegue de código.
MERGE INTO contenido_bienvenida (id, logo_url, video_url, version, activo)
KEY (id)
VALUES (
    1,
    'https://assets.resuelve.com/marca/logo-principal.png',
    'https://assets.resuelve.com/marca/video-bienvenida-v2.mp4',
    '2.1.0',
    TRUE
);
```

> **Nota**: La sentencia `MERGE INTO ... KEY (id)` funciona en H2 (tests). Para PostgreSQL
> (producción) usar `INSERT INTO ... ON CONFLICT (id) DO UPDATE SET ...`.

### Datos de Prueba (test resources)

Archivo: `backend/src/test/resources/db/test-data/contenido_marca_test_data.sql`

```sql
-- Datos adicionales exclusivos para las pruebas BDD/integración.
-- Se ejecutan después de las migraciones de Flyway al arrancar el contexto de prueba.
INSERT INTO contenido_bienvenida (id, logo_url, video_url, version, activo)
VALUES (
    99,
    'https://test-assets.resuelve.com/marca/logo-test.png',
    'https://test-assets.resuelve.com/marca/video-test.mp4',
    '0.0.1-TEST',
    FALSE
);
```

### Configuración de Perfiles Spring Boot

**`src/main/resources/application.yml`** (producción):
```yaml
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    driver-class-name: org.postgresql.Driver
  flyway:
    enabled: true
    locations: classpath:db/migration,classpath:db/data
    baseline-on-migrate: true
```

**`src/test/resources/application-test.yml`** (pruebas):
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:resuelve_test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1
    driver-class-name: org.h2.Driver
  flyway:
    enabled: true
    locations: classpath:db/migration,classpath:db/data,classpath:db/test-data
```

---

## DTO de la API (capa de Infraestructura)

El siguiente DTO es el modelo de respuesta del endpoint backend.
**Es generado automáticamente** por openapi-generator y NO se modifica a mano.

### ContenidoBienvenidaResponse (DTO)

| Campo | Tipo JSON | Descripción |
|-------|-----------|-------------|
| `logoUrl` | `string` (uri) | URL del logo |
| `videoUrl` | `string` (uri) | URL del video |
| `version` | `string` | Versión del contenido |

El `ContenidoMarcaGateway` (Adaptador) mapea este DTO a la entidad `ContenidoBienvenida` del dominio.

---

## Transiciones de Estado

```
[APP instalada]
     │
     ▼
VerificarPrimerUsoUC
     │
     ├──[bienvenidaVista = false]──► PantallaBienvenida
     │                                    │
     │                          ┌─────────┴─────────┐
     │                    [con red]           [sin red]
     │                          │                   │
     │                 ObtenerContenido      Mostrar logo
     │                  [éxito]  [fallo]    + "Continuar"
     │                     │       │
     │                Reproducir  Mostrar logo
     │                 video      + "Continuar"
     │                     │
     │              [video termina | toca "Continuar"]
     │                          │
     │                 MarcarBienvenidaVistaUC
     │                          │
     └──[bienvenidaVista = true]──► PantallaCedula
```
