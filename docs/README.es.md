# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Una aplicación macOS y una extensión Safari para enviar descargas a la aplicación **Descargas** de un NAS UGREEN en UGOS Pro, sin mantener abierta la página NAS.

Fuentes y versión DMG: **0.6.0**. Proyecto comunitario independiente, no afiliado a UGREEN ni a Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

La interfaz de la aplicación y la extensión está disponible en 34 idiomas.

## Características

- Intercepción de enlaces `.torrent` y `magnet:` en sitios autorizados en Safari.
- Acción **Descargar a NAS** haciendo clic derecho en un enlace, imagen, video o elemento de audio directamente accesible.
- Envío manual de un URL desde el menú de extensión.
- Cuenta y sesión en Llavero macOS; Soporte para autenticación de dos factores y confianza en el dispositivo.
- Busque opcionalmente NAS utilizando el servicio en línea UGREEN, o la dirección HTTPS manualmente.
- Lista de descargas, progreso y velocidad; Notificaciones opcionales de finalización, apagado y error.
- Identificación de nombres y tipos de archivos HTTP, con corrección de nombre después de la descarga cuando el archivo se identifica sin ambigüedades.
- Íconos nativos claros y oscuros, y logotipos Safari adaptados al tema del sistema.

## Compatibilidad

El proyecto está configurado para **macOS 27 o posterior** y se compiló con **Xcode 27.1**, para Apple Silicon. Las pruebas NAS se realizaron con un **DXP2800**, **UGOS Pro 1.20.0.0142** y **Descargas 1.19.1.0004**. Otras versiones no están garantizadas: la integración se basa en API observadas, sin un contrato público UGREEN estable.

## Instalar desde DMG

[Descargar UGREEN NAS Download 0.6.0 para Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Abra DMG, arrastre **UGREEN NAS Download** a **Aplicaciones** y luego abra la aplicación.
2. En **Safari → Configuración → Avanzado**, habilite las funciones para desarrolladores web. En **Desarrollador**, habilite **Permitir extensiones sin firmar**, luego habilite **UGREEN NAS Download** en **Extensiones**.
3. Configure NAS en la configuración de la extensión.

Este paquete público está firmado localmente (ad hoc) y no está certificado ante notario. macOS puede bloquear su apertura inicial. Safari puede solicitar volver a habilitar el permiso para extensiones sin firmar después de salir del navegador.

## compilar desde la fuente

1. Clona este repositorio y abre `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. En **Firma y capacidades**, elige tu propio equipo de Apple para los dos objetivos: la aplicación y su extensión. No se ingresa ningún equipo personal en el repositorio.
3. Elija el esquema **UGREEN NAS Download**, destino **Mi Mac**, luego compile y ejecute con Xcode.
4. Active la extensión en **Safari → Configuración → Extensiones**, luego autorice los sitios deseados.
5. Abra la configuración de la extensión y configure su NAS como se describe a continuación.

Los ID de paquete de ejemplo son `com.example.UGREENNASDownload` y `com.example.UGREENNASDownload.Extension`. Si necesita personalizarlos para su firma, modifique los identificadores de proyecto Xcode **y** las constantes correspondientes en `Extension/background.js` y `ViewController.swift`: los valores deben permanecer consistentes.

Esta edición pública utiliza identificadores y un espacio de llavero independiente de la aplicación de desarrollo personal. Requiere su propia configuración de NAS. La firma de desarrollo no constituye una distribución notariada y la activación puede requerir la configuración de desarrollo Safari apropiada para su firma.

Para consultar una compilación sin firma, desde la raíz del repositorio:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Esta verificación genera una solicitud sin firmar; utilice su equipo de Apple para una instalación de desarrollo utilizable en Safari. Mantenga el árbol del repositorio: las referencias Xcode a `Extension` y `Design` son relativas.

## Configurar NAS

1. Ingresa la dirección HTTPS de NAS con su puerto, tu identificador y la ruta de destino absoluta en NAS. Los campos personales están vacíos de forma predeterminada.
2. Haga clic en **Verificar certificado de NAS**. Compare la huella digital SHA-256 con una fuente confiable antes de confirmar el certificado.
3. Introduzca la contraseña y, si es necesario, un código de autenticación doble. Confiar en el dispositivo es opcional; sin él, es posible que se requiera un nuevo código cuando expire la sesión.
4. Haga clic en **Guardar y probar conexión**. Permitir el acceso a la red local cuando macOS lo solicite.
5. Habilite la interceptación automática de torrents e imanes si lo desea. El clic derecho y el envío manual siguen siendo independientes de este interruptor.

La dirección, la cuenta y la carpeta aún se pueden modificar en la configuración. **Olvidar esta cuenta** elimina la cuenta y su sesión de Llavero para el perfil actual Safari.

## Seguridad y operación

Las páginas web no pueden configurar la cuenta ni confiar en un certificado. La extensión se comunica con su módulo Swift a través de mensajería nativa. NAS las solicitudes pasan por un motor WebKit aislado con almacenamiento efímero y secuencias de comandos de página deshabilitadas; el certificado debe coincidir con la huella dactilar aprobada. NAS se rechazan las redirecciones. La contraseña se cifra con la clave RSA proporcionada por NAS, el HTTPS.

La contraseña, el token y la información de inicio de sesión se almacenan en Keychain, no en el almacenamiento web ni en este repositorio. El código temporal se borra después de su uso. Las cookies y los identificadores de sitios Safari nunca se transmiten a NAS. Para algunos torrents del mismo sitio, el archivo pequeño se recupera en la memoria con la sesión Safari, luego se transmite a NAS sin guardarlo localmente o SMB; su tamaño está limitado a 512 KiB.

La búsqueda automática consulta voluntariamente `api.ugnas.com`: este servicio ve la dirección IP pública de la conexión, pero no recibe una contraseña o token NAS. La entrada manual no depende de este servicio.

No se intentan nuevas adiciones después de que haya pasado una respuesta ambigua o una fecha límite. Sólo se permite una reconexión y un nuevo intento después de un rechazo explícito de la autenticación. **Una tarea aceptada por NAS no es prueba de que la descarga esté completa.**

## Límites

- Safari no reemplaza universalmente todas sus descargas. La interceptación automática cubre enlaces y mecanismos de torrents reconocidos; Al hacer clic con el botón derecho y la entrada manual se completa esta operación.
- Un enlace HTTP debe ser accesible directamente por NAS. Los contenidos protegidos de la sesión del sitio, vencidos URL, los videos protegidos y los archivos ordinarios generados en `blob:` o `data:` no se convierten en enlaces públicos.
- El seguimiento del menú espera aproximadamente 3,5 segundos después de cada respuesta; las notificaciones y correcciones de nombres se verifican aproximadamente cada 30 segundos. Safari una Mac cerrada, suspendida o inactiva puede retrasar estas operaciones.
- Los formatos desconocidos no reciben una extensión inventada. El cambio de nombre se produce una vez completada la descarga; el archivo real está fijo, mientras que el historial de descargas puede conservar su nombre original.
- Las correcciones se limitan a nuevas tareas HTTP identificadas inequívocamente, sin sustitución forzosa, con un máximo de 100 operaciones pendientes y una retención de siete días. Las listas están limitadas a 10.000 tareas por categoría.
- La configuración global macOS de los iconos sigue siendo prioritaria: **Oscuro → Automático** te permite seguir el tema. El ícono de la lista de extensiones estáticas Safari conserva su versión clara; Los logotipos de menú y opciones siguen el tema.

## Desarrollo y pruebas

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Las pruebas de JavaScript requieren Node.js; Las pruebas nativas requieren herramientas macOS, Xcode, Python 3 y OpenSSL. Inician un servidor HTTPS local temporal en el puerto 18443 y no utilizan ninguna cuenta NAS real. La auditoría 0.5.1 incluyó 45 pruebas de JavaScript y 121 controles nativos. Véase [informe](../AUDIT-0.5.1.md).

- `Extension/`: menú, configuraciones, scripts Safari e íconos.
- `Xcode/`: aplicación AppKit, módulo Swift, autenticación y transporte NAS.
- `Design/Adaptive/UGREENIcon.icon/`: ícono nativo con apariencia clara y oscura.
- `Design/generate-icons.swift`: generación de PNG y el logo adaptativo de la ventana.
- `Tests/`: pruebas de seguridad, validación de datos y comportamiento.

## Referencias

- [cliente de comunidad ugnas-api](https://github.com/Fracizz/ugnas-api): referencia de protocolo, sin código de terceros cargado desde una página NAS.
- [Integración de la comunidad UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referencia para doble autenticación.
- [Documentación de Apple Safari Extensiones web](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Para informar un problema, no adjunte ninguna contraseña, código temporal, token, firmado URL, torrent privado o exportación de llavero. Utilice datos ficticios en los ejemplos.
