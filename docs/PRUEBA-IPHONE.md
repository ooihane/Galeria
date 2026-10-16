# Prueba de viabilidad: Windows + iPhone

## Puerta de entrada

La compilación de dispositivo y simulador ha pasado en [GitHub Actions](https://github.com/ooihane/Galeria/actions/runs/38983623148).
La firma, instalación y renovación todavía no están probadas. No hay certificado de distribución ni membresía de pago.
La prueba requiere una cuenta Apple gratuita, conexión USB y una herramienta compatible
que firme personalmente el IPA en Windows. Consultar https://sideloadly.io/ y las
condiciones de Apple vigentes antes de introducir credenciales o instalar herramientas.
No usar herramientas descargadas de mirrors desconocidos. No desactivar antivirus ni
verificaciones TLS. No facilitar contraseñas ni códigos en GitHub, logs o chat.

Si Sideloadly no admite la versión exacta de iOS, o requiere una opción de pago para esta
ruta, detener la instalación y registrar el error. La compatibilidad no se presupone.
Los componentes Apple para Windows que necesite la herramienta deben instalarse según
sus instrucciones actuales; no mezclar versiones a ciegas.

## Instalación inicial

1. Confirmar iOS en Ajustes → General → Información y anotar el valor exacto.
2. Obtener el IPA del workflow después de sus builds correctos.
3. Conectar por USB, desbloquear el iPhone y autorizar la confianza en el ordenador.
4. Firmar e instalar el IPA con la herramienta gratuita compatible y la cuenta personal.
5. Si iOS lo exige, activar Modo de desarrollador y autorizar el perfil desde Ajustes,
   siguiendo los avisos reales del dispositivo. No dar por hecho que ambas opciones aparecen siempre.
6. Abrir Galería. Si falla, conservar el error completo sin datos de la cuenta.

No se necesita configurar una cuenta Apple en GitHub Actions.
La herramienta puede cambiar el identificador de la app para la firma gratuita:
conservar cuenta e identificador en renovaciones para evitar instalaciones separadas.

## Matriz de validación manual

Usar fotos sintéticas y un álbum de pruebas. No borrar la app durante la prueba de renovación.
Registrar resultado, versión de iOS, herramienta y fecha; no marcar pasos no ejecutados.

| Comprobación | Resultado inicial |
| --- | --- |
| Compilación de dispositivo y simulador en CI | Correcta, ejecución #1, commit `3a0a157` |
| Firma personal e instalación | Pendiente |
| Apertura en iPhone 13 | Pendiente |
| Permiso denegado: mensaje correcto, sin bloqueo | Pendiente |
| Permiso limitado: recuento restringido y aviso | Pendiente |
| Permiso completo: lectura de biblioteca | Pendiente |
| Carpetas anidadas y álbumes coinciden con Fotos | Pendiente |
| Cambio en Fotos actualiza la app | Pendiente |
| Favorito cambia en Fotos y se revierte al repetir | Pendiente |
| Crear álbum de prueba dos veces no lo duplica | Pendiente |
| Foto en iCloud: carga, error de red y cancelación | Pendiente |
| Vision detecta rostros en una foto sintética | Pendiente |
| Core Image muestra antes/después sin guardar cambios | Pendiente |
| Live Photo original sigue intacta | Pendiente |
| Renovar firma antes de caducar y conservar datos | Pendiente |
| Confirmar coste adicional 0 € | Pendiente |

El acceso a iCloud puede necesitar conexión y espacio temporal. La vista previa se limita a
1600 × 1600 como tamaño objetivo; esta prueba no solicita originales para análisis masivo.
No mide todavía el rendimiento sobre 89 GB ni valida la galería final.

## Renovación

La firma personal gratuita suele durar aproximadamente siete días; verificar la caducidad
real indicada por la herramienta. Renovar con la misma cuenta/identidad antes de que venza.
Comprobar el método manual primero. La renovación automática o inalámbrica permanece
pendiente de confirmar y no es un requisito que podamos dar por resuelto.
Si caduca, la app puede dejar de abrir hasta volver a firmarla.
No desinstalar para renovar: desinstalar puede borrar los datos privados de la app.
La fototeca de Apple no pertenece al almacenamiento privado de Galería.

## Criterio para continuar

No declarar viable la ruta gratuita hasta haber compilado, instalado y renovado en el
hardware real sin cargos. Si falla, diagnosticar el paso y no desarrollar el producto
completo sobre una ruta de instalación no demostrada.
