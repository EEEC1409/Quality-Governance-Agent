# Especificación de Funcionalidad: Pantalla de Bienvenida con Video de Marca

**Rama de Funcionalidad**: `001-bienvenida-video-marca`

**Creada**: 2026-06-27

**Estado**: Borrador

**Historia de Usuario**: US-01 · EPIC-01 · 2 pts

**Entrada**: Como cliente que instala la APP por primera vez, quiero ver la pantalla de bienvenida con el logo y un video de la marca Resuelve, para confirmar que estoy en la APP correcta y conocer la marca desde el primer contacto.

---

## Escenarios de Usuario y Pruebas *(obligatorio)*

### Historia de Usuario 1 — Primer acceso con conexión (Prioridad: P1)

El cliente abre la aplicación por primera vez en su dispositivo. La pantalla de bienvenida carga el logo de Resuelve y reproduce automáticamente el video de la marca. Al finalizar el video o al pulsar "Continuar", la APP avanza a la pantalla de ingreso de cédula.

**Por qué esta prioridad**: Es el punto de entrada absoluto de la aplicación. Sin esta pantalla el cliente no puede avanzar en ningún flujo. Define la primera impresión de la marca.

**Prueba independiente**: Puede probarse completamente instalando la APP en un dispositivo con conexión activa y verificando que el logo es visible, el video se reproduce y el botón "Continuar" navega a la siguiente pantalla.

**Escenarios de Aceptación**:

1. **Dado que** el cliente abre la APP por primera vez con conexión a internet,
   **Cuando** la pantalla de bienvenida carga,
   **Entonces** el logo de Resuelve es visible y el video de la marca comienza a reproducirse automáticamente sin intervención del usuario.

2. **Dado que** el video de la marca está reproduciéndose,
   **Cuando** el video termina completamente,
   **Entonces** la APP avanza automáticamente a la pantalla de ingreso de cédula.

3. **Dado que** el video de la marca está reproduciéndose o ya terminó,
   **Cuando** el cliente toca el botón "Continuar",
   **Entonces** la APP avanza inmediatamente a la pantalla de ingreso de cédula.

---

### Historia de Usuario 2 — Primer acceso sin conexión (Prioridad: P2)

El cliente abre la aplicación por primera vez pero el dispositivo no tiene conexión a internet. La pantalla de bienvenida se muestra con el logo de la marca y el botón "Continuar" disponible; el video puede omitirse sin bloquear el flujo.

**Por qué esta prioridad**: La conectividad móvil no es garantizada. La APP no debe quedar inutilizable por falta de red en el primer arranque.

**Prueba independiente**: Puede probarse poniendo el dispositivo en modo avión antes de abrir la APP y verificando que el logo se muestra y el botón "Continuar" es funcional.

**Escenarios de Aceptación**:

1. **Dado que** el dispositivo no tiene conexión a internet,
   **Cuando** el cliente abre la APP por primera vez y la pantalla de bienvenida carga,
   **Entonces** el logo de Resuelve se muestra siempre y el botón "Continuar" está habilitado y visible.

2. **Dado que** el dispositivo no tiene conexión a internet,
   **Cuando** la pantalla de bienvenida carga,
   **Entonces** la ausencia del video no muestra mensajes de error al usuario ni bloquea la navegación.

3. **Dado que** el dispositivo no tiene conexión a internet y el cliente toca "Continuar",
   **Cuando** ocurre el evento de toque,
   **Entonces** la APP avanza a la pantalla de ingreso de cédula con normalidad.

---

### Casos Límite

- ¿Qué ocurre si la conexión se pierde a mitad de la carga del video? → El video se omite silenciosamente y el botón "Continuar" permanece disponible.
- ¿Qué ocurre si el video no está disponible en el servidor? → La pantalla se comporta igual que el escenario sin conexión: logo visible y "Continuar" habilitado.
- ¿Qué ocurre si el cliente fuerza el cierre de la APP y la vuelve a abrir antes de tocar "Continuar"? → La pantalla de bienvenida se muestra nuevamente (comportamiento idempotente en primer uso).
- ¿Qué ocurre si el dispositivo tiene sonido en silencio? → El video se reproduce sin audio; la experiencia visual no se ve afectada. **Exclusión explícita**: este comportamiento es gestionado íntegramente por el sistema operativo y el reproductor de video del dispositivo; la APP no requiere lógica adicional y este escenario queda fuera del alcance de las pruebas automatizadas.

---

## Requisitos *(obligatorio)*

### Requisitos Funcionales

- **RF-001**: La APP DEBE mostrar el logo de Resuelve en la pantalla de bienvenida en todas las condiciones de conectividad.
- **RF-002**: La APP DEBE iniciar la reproducción del video de la marca automáticamente cuando existe conexión a internet y el recurso de video está disponible.
- **RF-003**: La APP DEBE mostrar el botón "Continuar" en la pantalla de bienvenida en todo momento, independientemente del estado del video o la conectividad.
- **RF-004**: La APP DEBE navegar a la pantalla de ingreso de cédula cuando el video termine o cuando el cliente toque "Continuar", lo que ocurra primero.
- **RF-005**: La APP DEBE omitir el video silenciosamente (sin mostrar errores) cuando no hay conexión o el recurso no está disponible.
- **RF-006**: La pantalla de bienvenida DEBE mostrarse únicamente durante el primer acceso del cliente a la APP.

### Entidades Clave

- **Pantalla de Bienvenida**: componente visual de primer contacto; atributos: logo (estático), video de marca (opcional según conectividad), botón "Continuar".
- **Estado de Primer Uso**: indicador persistente en el dispositivo que determina si la pantalla de bienvenida debe mostrarse; cambia a "ya visto" una vez que el cliente avanza a la pantalla de cédula.
- **Recurso de Video de Marca**: contenido multimedia de Resuelve; puede residir en red o en caché local; su ausencia no bloquea el flujo.

---

## Criterios de Éxito *(obligatorio)*

### Resultados Medibles

- **CE-001**: El 100% de los clientes que abren la APP por primera vez ven el logo de Resuelve antes de ingresar su cédula, independientemente del estado de la red.
- **CE-002**: El 100% de los clientes pueden avanzar a la pantalla de cédula desde la bienvenida en condiciones de conectividad y sin conectividad.
- **CE-003**: La pantalla de bienvenida carga y muestra el logo en menos de 2 segundos desde el inicio de la APP, con o sin conexión.
- **CE-004**: Ningún cliente ve mensajes de error relacionados con el video en la pantalla de bienvenida.
- **CE-005**: En condiciones de red estable y recurso de video disponible (escenario controlado), el reproductor de video inicia la reproducción en menos de 3000 ms desde que el widget de la pantalla de bienvenida es visible.

---

### Métricas de Monitoreo Post-Lanzamiento

Los siguientes indicadores se verifican en producción con herramientas de observabilidad, no con pruebas automatizadas en CI:

- **MON-01**: Tasa de arranques en los que el video se reproduce automáticamente (meta: ≥ 95% de sesiones con conexión activa y CDN disponible).
- **MON-02**: Tasa de errores del endpoint `/v1/marca/contenido-bienvenida` en producción (meta: < 0.1% de peticiones con error 5xx).

---

## Supuestos

- El logo de Resuelve es un recurso estático empaquetado con la APP; no requiere conexión a internet para mostrarse.
- El video de la marca se obtiene desde un servicio de red; no se asume disponibilidad sin conexión salvo que exista caché previa.
- La pantalla de bienvenida se muestra exclusivamente en el primer arranque; los accesos posteriores omiten esta pantalla y navegan directamente al flujo de autenticación.
- El botón "Continuar" es visible en todo momento (no se oculta mientras el video está en reproducción).
- El video no contiene subtítulos obligatorios ni elementos de accesibilidad que deban gestionarse en esta historia; se abordará en una historia específica de accesibilidad si aplica.
- La navegación a la pantalla de ingreso de cédula es la única acción de salida de esta pantalla; no existe opción de "Omitir" separada del botón "Continuar".
