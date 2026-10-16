# ESPECIFICACIÓN MAESTRA PARA CODEX — GALERÍA DE FOTOS PARA IPHONE

Versión de planificación: 1.0 (17 de octubre de 2026)
Estado: DISEÑO Y PLANIFICACIÓN. **NO EMPEZAR A PROGRAMAR TODAVÍA.**

## 0. Instrucción directa a Codex

Actúa como arquitecto, diseñador de producto y, solo cuando reciba autorización explícita, como agente principal de programación. Lee íntegramente este documento como fuente inicial de requisitos. **Tu primera respuesta debe ser una revisión estructurada del alcance, las limitaciones verificadas de iOS, la arquitectura propuesta, las fases de implementación y las decisiones pendientes. No escribas código, no crees archivos, no inicies un repositorio ni ejecutes tareas de instalación hasta que el usuario lo autorice.**

Se pretende que Codex haga prácticamente **el 100 % de la programación**: generar archivos, compilar mediante automatización, diagnosticar errores, escribir pruebas y proponer instrucciones de instalación. El usuario no quiere escribir código a mano.

## 1. Restricciones innegociables

- Plataforma de uso: **iPhone, aplicación nativa**.
- Equipo del usuario: **ordenador con Windows y sin acceso a Mac**.
- Herramienta principal de desarrollo: **Codex**.
- **Presupuesto adicional: 0 €**. No exigir Apple Developer de pago, servicios de IA con facturación, suscripciones ni servidores de pago. Utilizar herramientas gratuitas dentro de sus cuotas; parar antes de generar costes.
- Uso principalmente personal; posibilidad de compartir con conocidos **solo si no implica gastos** y explicando que cada uno tendría que instalar/firmar por su cuenta.
- Máxima privacidad: procesar imágenes, índices de reconocimiento y análisis **en el dispositivo** siempre que sea viable; no subir fotos ni datos faciales a servidores por defecto.
- Fuente de verdad: **fototeca real de Fotos de Apple**, no una galería duplicada. Respetar permisos, álbumes, cambios e iCloud conforme a APIs públicas.
- No prometer acceso a funciones internas de Fotos, ni omitir confirmaciones de seguridad que iOS imponga.
- No usar datos privados reales en pruebas de borrado.

## 2. Filosofía de diseño

Interfaz nativa, minimalista, moderna y fluida. Tres pestañas principales: **Fotos**, **Álbumes** y **Organizar**. Texto en español. Compatible con apariencia clara y oscura. Iconografía SF Symbols. Fácil de usar con una mano, con acciones directas y selección múltiple. No saturar la pantalla principal de herramientas.

## 3. Primera pestaña: FOTOS

- Pantalla de inicio por defecto con **todas las fotos y vídeos** de la fototeca autorizada, organizados cronológicamente.
- Cuadrícula fluida, miniaturas eficientes, agrupación por mes/fecha, zoom de cuadrícula, visor a pantalla completa.
- Búsqueda y filtros: Todas, Fotos, Vídeos, Favoritas, Capturas, Editadas si pueden identificarse, y Sin álbum; no inventar metadatos inaccesibles.
- Selección múltiple y acciones: añadir a álbum, mejorar automáticamente, comparar, marcar/desmarcar favorita, preparar eliminación, compartir según API disponible.
- Mostrar información básica de una imagen: fecha, dimensiones, ubicación cuando esté disponible, álbumes conocidos.
- Soportar fotos/vídeos alojados en iCloud que necesiten descarga; mostrar progreso y errores comprensibles.

## 4. Segunda pestaña: ÁLBUMES

### 4.1 Respetar álbumes y carpetas existentes

- Al dar acceso completo a Fotos, leer los **álbumes personales** y **carpetas anidadas** existentes con PhotoKit y mostrar su estructura real, sin importar, clonar ni mover archivos.
- Permitir crear, renombrar y gestionar álbumes y añadir/quitar fotografías mediante operaciones autorizadas de PhotoKit, para que se reflejen también en Fotos de Apple.
- Actualizar los cambios realizados en la app Fotos mediante observación/sincronización de PhotoKit.

### 4.2 Vista inteligente «Sin álbum» (requisito esencial)

- Es una **vista virtual** calculada, no un álbum físico ni una copia de fotos.
- Mostrar únicamente elementos que **no pertenecen a ningún álbum personal editable** accesible en la fototeca.
- NO considerar como álbum personal para este cálculo los agrupamientos inteligentes de Apple como **Favoritos, Capturas de pantalla, Vídeos, Selfies**, etc. Una foto que solo esté en Favoritos debe seguir apareciendo en «Sin álbum».
- Incluir correctamente los álbumes que estén dentro de carpetas anidadas.
- Cuando una foto se añada a cualquier álbum personal, desaparecerá de «Sin álbum». Si se quita de todos ellos, reaparecerá.
- Filtro por mes, incluido mes actual y mes anterior, selección masiva, asignación a álbum existente o nuevo.
- Si la autorización a fotos es limitada, avisar de que «Sin álbum» no puede considerarse exhaustivo y proponer acceso completo.
- Precisar y probar qué hacer con elementos de álbumes compartidos/no expuestos por PhotoKit: nunca declarar que están «sin álbum» por suposiciones no contrastadas.

### 4.3 Favoritos: requisito actualizado

- Debe aparecer un álbum accesible llamado **«Favoritos»**, utilizando directamente el **álbum inteligente de Favoritos de Apple** y su estado real.
- Se puede disponer de un **botón corazón explícito** en el visor o en acciones de selección para marcar/desmarcar favorito, sincronizando el cambio con Apple.
- **ELIMINAR por completo la función «Protección de favoritas»**. No bloquear el borrado de las favoritas, no añadir confirmaciones extra por ser favoritas, no incluir ningún ajuste de «proteger favoritas» ni estados de bloqueo.
- **ELIMINAR el gesto de pulsación larga para marcar favorita o proteger**. No reutilizar ese gesto para tales acciones. Si existe pulsación larga en cuadrícula para seleccionar, no debe modificar el estado Favoritos.

### 4.4 Personas (nuevo requisito)

- El usuario quiere **agrupar fotos por personas mediante reconocimiento facial**, para poder seleccionar muchas fotos de una misma persona y añadirlas a un álbum rápidamente.
- **Prioridad de compatibilidad**: investigar si existe una API pública y permitida para reutilizar los grupos/nombres de «Personas y mascotas» de Fotos de Apple. **No asumir que PhotoKit los expone**; actualmente no hay API pública documentada equivalente a la consulta de álbumes personales o Favoritos.
- Si no puede reutilizarse el reconocimiento de Fotos, proponer un **índice facial propio y local**, independiente de Apple: detección de caras, agrupación por similitud, revisión del usuario, asignación manual de nombres y corrección de coincidencias erróneas.
- Entrada «Personas» dentro de Álbumes o de la búsqueda: mosaico con rostros, grupo de fotos por persona, selección masiva y acción «Añadir a álbum».
- Detección de rostro no significa identificación fiable. Comprobar técnica/modelos disponibles, precisión, rendimiento, licencia y soporte real de iOS; no prometer reconocimiento perfecto ni que los nombres propios se sincronicen con «Personas y mascotas» de Apple.
- Exigir consentimiento claro, **procesamiento local por defecto**, opción para desactivar el análisis y borrar el índice facial de la aplicación. No subir plantillas ni caras a servicios externos.
- Considerar fotos con varias personas: una imagen puede pertenecer a varios grupos faciales.

## 5. Tercera pestaña: ORGANIZAR

Pantalla central con accesos a: **Organizar por gestos**, **Sin álbum por mes**, **Duplicados y similares**, **Comparador**, **Liberar espacio** e **Historial / Deshacer**.

### 5.1 Modo de gestos

- Foto grande en pantalla, contador y contexto («Sin álbum · Octubre», «Todas», etc.).
- **Deslizar izquierda**: siguiente foto.
- **Deslizar derecha**: foto anterior.
- **Deslizar arriba**: conservar / pasar a la siguiente, sin borrarla ni añadirla automáticamente a álbum.
- **Deslizar abajo**: marcar para una **cola de borrado**, ocultarla inmediatamente de esta sesión y pasar a la siguiente, **sin diálogos por foto**.
- Navegación accesible también mediante botones visibles; botón «Añadir a álbum», icono de favorito normal si corresponde y deshacer la última decisión.
- Al terminar la sesión, revisar y ejecutar el borrado en bloque mediante PhotoKit. **Respetar cualquier confirmación obligatoria de iOS**; no prometer que puede omitirse.
- Tras borrarse de Fotos, el comportamiento de «Eliminado recientemente» lo controla Apple. La app no debe fingir tener acceso a la carpeta protegida ni prometer restauración automática.
- La «Papelera pendiente» en nuestra interfaz es solo el **lote previo a confirmar**, no equivale a «Eliminado recientemente».

### 5.2 Duplicados y similares

- Identificar archivos idénticos y fotografías visualmente similares, con grupos separados (duplicado exacto, similar, posible ráfaga).
- Modo acordado: **«Recomendación inteligente»**. Para cada grupo señalar la mejor foto sugerida según nitidez, exposición, resolución u otros indicadores realmente implementados.
- El usuario decide cuáles conservar o eliminar; **nunca eliminar automáticamente**.
- Mostrar comparación grande y permitir conservar varias.
- No introducir una protección o confirmación especial por el hecho de ser favorita (se eliminó expresamente), aunque se puedan mostrar indicadores informativos.

### 5.3 Organización mensual

- Ver fotos de un mes concreto que aún estén «Sin álbum»; asignarlas en masa a álbumes existentes o nuevos.
- Conservar progreso de revisión de la sesión sin alterar el estado de las fotos hasta que se produzca una acción real.

### 5.4 Liberar espacio

- Detectar vídeos grandes, capturas antiguas, archivos voluminosos, duplicados y posibles fotos borrosas.
- Mostrar **tamaño estimado de los archivos y ahorro potencial**, nunca prometer que será exactamente el almacenamiento local liberado, especialmente con «Optimizar almacenamiento del iPhone» e iCloud.
- Antes de eliminar, vista previa y revisión de lotes. Sin borrado automático.

### 5.5 Comparador

- Comparación en paralelo de 2 o varias fotos, ampliación sincronizada cuando sea útil, datos de resolución/nitidez/exposición y recomendación de mejor foto si hay base técnica.
- Modos «Rápido» y «Detallado»; el usuario siempre decide.

### 5.6 Historial y deshacer

- Registrar decisiones de sesión, cambios de pertenencia a álbumes y mejoras/ediciones que puedan revertirse.
- Botón «Deshacer» para acciones aún pendientes y operaciones reversibles.
- No prometer deshacer un borrado ya confirmado por Fotos; indicar que se recupera desde «Eliminado recientemente» de Apple, si aún está disponible.

## 6. EDICIÓN INDIVIDUAL Y MASIVA

### 6.1 Mejora automática por lotes (aprobada)

- Permitir seleccionar numerosas fotos desde Fotos o Álbumes y procesarlas en una sesión.
- **Analizar cada foto individualmente**, no aplicar indiscriminadamente el mismo filtro a todas.
- Cuatro funciones activadas por defecto: **(1) luz y exposición, (2) color natural, (3) calidad y nitidez, (4) corrección de defectos**.
- Enderezado automático **NO activado por defecto**.
- Intensidad orientativa: Suave, Normal, Intensa.
- Mostrar vista antes/después, resultados por imagen, barra de progreso, cancelación y edición manual posterior.
- Preferir **edición no destructiva/reversible** mediante mecanismos compatibles con PhotoKit. Cuando no sea posible, ofrecer guardado como copia preservando original y explicar costes de almacenamiento.
- No atribuir capacidades inexistentes al procesamiento automático local (p. ej., restauración generativa completa) ni alterar caras involuntariamente.

### 6.2 Editor manual y «Editar con IA»

- Editor individual de exposición, brillo, contraste, sombras, altas luces, color y nitidez.
- Acceso separado «Editar con IA»: peticiones como eliminar objetos, modificar fondo o restaurar foto.
- **Sin APIs de pago**. La IA generativa avanzada es una **fase futura condicionada** a hallar un modelo local compatible, gratis y con rendimiento suficiente. Si no es viable, dejar esta función como «pendiente», no incorporar costes ni prometer implementación.
- Nunca subir fotos a un servicio online sin autorización explícita y una evaluación clara de costes y privacidad.

## 7. BÚSQUEDA Y CLASIFICACIÓN INTELIGENTE

- Buscar por mes/fecha, álbum, tipo de contenido, texto reconocido dentro de fotos (OCR), objetos/escenas que modelos locales realmente permitan detectar y, cuando el agrupamiento facial propio esté disponible, nombre de persona asignado dentro de la app.
- Mostrar sugerencias de clasificación por contenido/fecha/personas. Las sugerencias **no modifican álbumes sin confirmación del usuario**.
- Priorizar Apple Vision y modelos Core ML locales compatibles; documentar límites de idioma, precisión, uso de batería y tamaño de índice.

## 8. REQUISITOS DE FUNCIONAMIENTO Y PRIVACIDAD

- PhotoKit como integración con biblioteca Apple y sus cambios; Vision para detección/análisis visual; Core Image para ajustes fotográficos; SwiftUI para UI.
- Analizar y almacenar solo los metadatos/índices indispensables dentro del espacio privado de la app; evitar duplicar todas las fotos.
- Adaptación a bibliotecas con decenas de miles de activos: carga bajo demanda, miniaturas cacheadas con límites, análisis incremental, estado de progreso, pausa/cancelación, ahorro de memoria y batería.
- Considerar activos HEIC, JPEG, Live Photos, vídeos, y casos RAW según soporte real. Nunca perder la parte de vídeo asociada a una Live Photo al editar.
- Manejar permisos denegados/limitados; errores de iCloud y archivos no descargados; cambios mientras se usa la app.
- No introducir un sistema de cuentas, nube propia ni publicidad.
- Mantener historial/índices locales según lo permitido por el sistema y posibilidad de borrar datos de análisis personales.
- Primeras pruebas con una **fototeca ficticia/de prueba** y operaciones destructivas simuladas.

## 9. PLAN TÉCNICO GRATUITO Y SIN MAC

Ruta de trabajo inicial propuesta, **a verificar mediante una prueba técnica antes de implementar toda la app**:

1. Codex en Windows crea/mantiene el proyecto SwiftUI y los scripts de construcción cuando el usuario autorice comenzar.
2. Repositorio **GitHub** (preferentemente privado por seguridad del proyecto) con control de versiones.
3. **GitHub Actions con runner macOS** para compilar el proyecto desde la nube, manteniendo el consumo dentro de cuotas gratuitas. Analizar cuotas para repos privados y bloquear cualquier gasto.
4. Generar un artefacto compatible con firma/instalación personal sin certificado de distribución de pago, **solo si técnicamente funciona**; no prometer que un IPA de CI sin firmar será instalable sin más.
5. Explorar **Sideloadly en Windows** u otra alternativa gratuita compatible para firmar/instalar en el iPhone sin jailbreak. Verificar compatibilidad con la versión actual de iOS y las capacidades necesarias de la app.
6. Asumir la **caducidad de aproximadamente siete días** de la firma personal gratuita y la necesidad de renovación. No prometer distribución fácil mediante enlaces ni instalación permanente.
7. Para conocidos, exigir instalación y firma individuales cuando sea legal y técnicamente viable; **no pagar** membresía o TestFlight de distribución.

### Validación técnica obligatoria antes de programar el producto completo

Verificar explícitamente:
- ¿Podemos construir y firmar/instalar una app SwiftUI mínima desde Windows + CI macOS + método gratuito de sideload?
- ¿La firma gratuita permite las capacidades concretas de PhotoKit/Vision que necesitamos?
- ¿Qué API de PhotoKit permite observar favoritos, álbumes y carpetas anidadas? ¿Qué **no** permite leer, especialmente «Personas y mascotas» y «Eliminado recientemente»?
- ¿El reconocimiento facial agrupado puede realizarse localmente con una solución fiable, de licencia gratuita y aceptable para iOS?
- ¿Qué estrategia viable ofrece edición no destructiva, preservación de metadatos y Live Photos?

Si alguna pieza no resulta posible gratuitamente, **informar antes de programar** y proponer la alternativa gratuita más cercana sin afirmar una compatibilidad no demostrada.

## 10. PLAN POR FASES (sin ejecutar aún)

**Fase 0 — Arquitectura y viabilidad**: auditar APIs y validar instalación gratis, desglose de alcance y riesgos.

**Fase 1 — Galería**: autorización y lectura PhotoKit, cuadrícula Fotos, visor, álbumes existentes y favoritos nativos.

**Fase 2 — Clasificación**: «Sin álbum» correcto, carpetas anidadas, organización mensual, selección múltiple y asignación a álbumes.

**Fase 3 — Gestos y seguridad**: revisión por gestos, cola de descarte, confirmación agrupada, historial/deshacer.

**Fase 4 — Limpieza**: duplicados y similares, recomendaciones revisables, comparador y almacenamiento.

**Fase 5 — Edición**: ajustes manuales, mejora automática individual por foto en lotes, previsualización y reversibilidad.

**Fase 6 — Inteligencia local**: búsqueda de contenido, OCR, sugerencias de álbum y agrupamiento facial propio (si viable), todo optativo y privado.

**Fase 7 — IA generativa**: solo si se demuestra posible sin coste adicional y sin sacrificar privacidad ni rendimiento.

## 11. CRITERIOS DE ACEPTACIÓN PRINCIPALES

1. Todos los álbumes personales accesibles desde Fotos de Apple se ven con la estructura correspondiente sin importación manual.
2. Una foto que ya está en un álbum personal **no aparece** en «Sin álbum»; una foto que solo está en Favoritos **sí puede aparecer**.
3. Añadir desde nuestra app una foto a un álbum la incorpora al álbum de Fotos de Apple y actualiza inmediatamente «Sin álbum».
4. El álbum Favoritos refleja el de Apple; **no hay protecciones especiales ni gesto largo de favorito**.
5. El gesto abajo añade a la cola y avanza sin preguntar por cada foto; el borrado real solo se ejecuta tras la revisión final y las confirmaciones del sistema.
6. El detector señala recomendaciones, pero **nunca borra sin decisión del usuario**.
7. La mejora masiva evalúa cada imagen separadamente, con los cuatro ajustes por defecto y originales preservados de forma demostrable.
8. «Personas» sirve para identificar grupos de rostros y clasificar fotos en álbumes; si los nombres de Apple son inaccesibles, se indica claramente que el índice es independiente y local.
9. La aplicación no requiere servicios, suscripciones ni APIs de pago; toda limitación del método de instalación gratuita queda documentada.
10. No hay eliminación irreversible silenciosa ni promesas falsas sobre recuperar fotos de «Eliminado recientemente».

## 12. PRIMERA RESPUESTA QUE SE ESPERA DE CODEX

**No hagas cambios en el proyecto todavía.** Entrega:

A. Resumen de requisitos definitivos (destacando la eliminación de la protección de favoritas y la inclusión de reconocimiento facial).

B. Tabla de viabilidad: «confirmado por API pública / posible con implementación local / incierto por limitaciones de Apple / no viable gratis».

C. Propuesta de navegación y pantallas, con flujos clave.

D. Diseño de arquitectura SwiftUI/PhotoKit/Vision/Core Image y almacenamiento local.

E. Primera prueba de viabilidad que propones ejecutar más adelante para compilar e instalar desde Windows sin pagar.

F. Lista breve de decisiones verdaderamente imprescindibles que faltan antes de escribir código.

Después **espera autorización explícita del usuario para empezar la implementación**.

---

Fuentes técnicas a consultar y contrastar contra las versiones vigentes:
- PhotoKit: https://developer.apple.com/documentation/photos/
- Favoritos: https://developer.apple.com/documentation/photos/phassetcollectionsubtype/smartalbumfavorites
- Vision: https://developer.apple.com/documentation/vision
- GitHub Actions precios: https://docs.github.com/en/billing/concepts/product-billing/github-actions
- Limitaciones de cuenta Apple gratuita: https://developer.apple.com/help/account/basics/about-your-developer-account
