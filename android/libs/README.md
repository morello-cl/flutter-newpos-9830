# SDK de firmware Newpos (dependencia propietaria)

Este plugin compila contra el SDK de plataforma del terminal Newpos, distribuido
por el fabricante como un único `sdk.jar`. Ese archivo contiene software
**propietario de terceros** y **no se versiona** en este repositorio.

## Bibliotecas requeridas para compilar

`android/libs/sdk.jar` aporta estos paquetes (ninguno incluido aquí):

| Paquete | Para qué |
|---------|----------|
| `com.pos.device.*` | API de periféricos: impresora, scanner, banda magnética, ICC/PSAM, configuración y sistema del terminal. |
| `com.secure.api.*` | API de seguridad de plataforma que el SDK usa internamente. |

Se enlazan como `compileOnly`: el **firmware del terminal** provee las clases en
tiempo de ejecución vía `<uses-library android:name="com.pos.device" />`, de modo
que **no se empaqueta ningún binario propietario** en la aplicación.

## Para compilar

El plugin busca el `sdk.jar` en dos ubicaciones (gana la primera que lo tenga):

1. **Consumiendo por `path:` (desarrollo local)** — dentro de este repo:
   ```
   android/libs/sdk.jar
   ```
2. **Consumiendo por git o pub.dev** — el paquete publicado **no** trae el jar;
   cada app consumidora coloca el suyo en:
   ```
   <tu_app>/android/newpos-sdk/sdk.jar
   ```

Sin el archivo en alguna de las dos, el plugin no compila.

## Distribución automática (GitHub Packages) — recomendado

Para no copiar el jar a mano en cada máquina, se publica **una vez** en un
registro Maven **privado** (GitHub Packages) y Gradle lo descarga solo en cada
build. El `android/build.gradle` ya está configurado: usa el jar local si
existe; si no, baja `cl.mufin:newpos-sdk` del repo privado (requiere token).

> ⚠️ El repo que aloja el paquete **debe ser privado**. GitHub Packages hereda
> la visibilidad del repo: publicarlo en uno público expondría el SDK.

### Una vez por versión del SDK (quien tenga el jar)

1. Crea un repo **privado** para el paquete, p. ej. `morello-cl/newpos-sdk`.
2. Publica el jar como artefacto Maven (con un PAT con scope `write:packages`):

   ```bash
   mvn deploy:deploy-file \
     -DgroupId=cl.mufin -DartifactId=newpos-sdk -Dversion=1.0.0 -Dpackaging=jar \
     -Dfile=android/libs/sdk.jar \
     -DrepositoryId=github \
     -Durl=https://maven.pkg.github.com/morello-cl/newpos-sdk
   ```

   con `~/.m2/settings.xml`:

   ```xml
   <settings><servers><server>
     <id>github</id>
     <username>TU_USUARIO_GH</username>
     <password>PAT_CON_write:packages</password>
   </server></servers></settings>
   ```

   Al subir un SDK nuevo, sube `-Dversion` y el `newposSdkVersion` del consumidor.

### Una vez por máquina / CI (cada desarrollador)

Un PAT con scope `read:packages` en `~/.gradle/gradle.properties` (global, no por
proyecto):

```properties
gpr.user=tu_usuario_github
gpr.token=ghp_xxx_con_read_packages
```

(o variables de entorno `GITHUB_ACTOR` / `GITHUB_TOKEN`; en CI, como secrets.)

A partir de ahí, `flutter build` descarga el jar automáticamente. Sin token,
Gradle cae al jar local. Overridables: `newposSdkRepo`, `newposSdkVersion`.

## ⚠️ Aviso legal y de responsabilidad

**Lea esto antes de incorporar el SDK.**

- El `sdk.jar` y los paquetes `com.pos.device.*` y `com.secure.api.*` son
  **software propietario del fabricante del terminal (Newpos / asmart) y de sus
  licenciantes**. **No** están cubiertos por la licencia MIT de este repositorio,
  **no** se distribuyen con él y **no** pueden redistribuirse sin autorización
  expresa del titular.
- **Su obtención y uso están sujetos a los contratos, licencias y autorizaciones
  vigentes entre el usuario y el fabricante.** Utilizar el SDK **sin contar con
  esos permisos está prohibido** y puede infringir derechos de propiedad
  intelectual, obligaciones contractuales y la normativa aplicable (incluida la
  certificación PCI cuando corresponda). Es **responsabilidad única y exclusiva
  del usuario** verificar y disponer de dichos derechos antes de compilar,
  distribuir o desplegar cualquier aplicación basada en este plugin.
- Este proyecto es únicamente un **envoltorio de código abierto**. Sus autores
  **no** son el fabricante del SDK, **no** tienen relación con él, **no** conceden
  ningún derecho, licencia ni autorización sobre el SDK, **no** lo redistribuyen y
  **declinan toda responsabilidad** —directa o indirecta— derivada de su
  obtención, licenciamiento, uso o mal uso. El software se entrega «TAL CUAL»,
  sin garantías de ningún tipo (ver [`LICENSE`](../../LICENSE)).
- Al incorporar el SDK, el usuario **asume íntegramente** dicha responsabilidad y
  mantiene indemnes a los autores de este envoltorio frente a cualquier reclamo.
