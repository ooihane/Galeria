# Galería para iPhone

Aplicación nativa personal, en español, basada en la fototeca real de Apple.
**Estado: primera prueba técnica implementada; compilación con Xcode e instalación física pendientes.**

La [especificación maestra](docs/ESPECIFICACION.md) conserva el alcance completo.
La autorización posterior del usuario permite implementar primero la prueba de viabilidad.
No se han validado aún la compatibilidad con iOS 26.6.2 ni las condiciones actuales del método gratuito.

## Prueba implementada

- Tres pestañas nativas, acceso completo/limitado/denegado a Fotos.
- Recuento de elementos y favoritos, listado de los 60 más recientes.
- Lectura recursiva de álbumes y carpetas accesibles, observación de cambios.
- Vista previa de fotos bajo demanda, descarga de iCloud con progreso y cancelación.
- Cambio de favorito real, previa confirmación general de esta prueba; no hay protección especial de favoritas.
- Creación explícita de un álbum vacío de prueba, reutilizando su nombre si ya existe.
- Detección local de rostros con Vision; **no identificación ni agrupación facial**.
- Previsualización Core Image de reducción de ruido/nitidez; no guarda cambios ni representa aún la mejora adaptativa.

No hay borrado, subida de fotos a servicios propios, guardado de ediciones ni claves de terceros.
Los vídeos se cuentan/listan, pero su reproducción queda para la fase de galería.
Live Photos muestran solo el fotograma de vista previa; nunca se reescriben.
La reducción de ruido no recupera detalles ausentes en fotos con zoom.

## Compilación desde Windows

El proyecto requiere Xcode en macOS para compilar. Windows se utiliza para descargar,
firmar e instalar el paquete; no necesita escribir código ni instalar Python para usar el artefacto.
El repositorio incluye un workflow **manual**, sin ejecución automática por push ni por pull request.

1. Una vez publicado este código en GitHub, comprobar primero en Billing/Actions la cuota
   incluida, cómo se factura macOS y que no se permite gasto adicional. No introducir un
   método de pago para esta prueba. Si no se puede garantizar coste cero, no ejecutar.
2. En Actions, ejecutar **Prueba iOS (manual)** sobre la rama con estos archivos.
3. Descargar el artefacto `Galeria-unsigned` cuando ambos builds terminen correctamente.
4. Extraer `Galeria-unsigned.ipa`. **No se instala directamente: está sin firmar.**
5. Seguir [la prueba en Windows e iPhone](docs/PRUEBA-IPHONE.md).

El límite de 15 minutos y la ejecución manual reducen consumo, pero **no garantizan coste cero**.
El workflow no contiene certificados, cuentas Apple ni secretos. No publica ni distribuye la app.
Usa el Xcode predeterminado de `macos-15`; registra su versión en el log. Si deja de ser
compatible con el dispositivo/SDK, habrá que revisar el runner antes de seguir.

## Desarrollo y comprobaciones

En macOS con Xcode completo y Python 3:

```sh
bash scripts/build-ios.sh
```

Genera el proyecto reproducible, compila para dispositivo sin firma y empaqueta un IPA.
El proyecto y el esquema generados están incluidos para no requerir XcodeGen, Homebrew ni paquetes externos.
Swift 5, mínimo iOS 17, iPhone. Sin capacidades de iCloud propias: PhotoKit accede a la fototeca del sistema.

Comprobaciones del empaquetador, ejecutables también en Linux:

```sh
python3 -m unittest discover -s tests -v
```

Estas pruebas usan archivos ficticios: **no compilan Swift, no ejecutan la app y no prueban firma**.
No confundirlas con la validación pendiente del iPhone.

## Restricciones y siguientes pasos

Dispositivo indicado: iPhone 13; Windows 11 Home; 89 GB en Fotos en iCloud con
Optimizar almacenamiento. Firma gratuita periódica aceptada. Versiones exactas del
sistema y compatibilidad de Sideloadly deben comprobarse en el dispositivo y en fuentes vigentes.

Primero: build real, instalación, permisos y renovación conservando datos.
Después: cuadrícula/visor completos, Sin álbum, clasificación, gestos, limpieza,
edición reversible e inteligencia local, según la especificación.
No se promete acceso al índice Personas de Apple ni a Eliminado recientemente.
