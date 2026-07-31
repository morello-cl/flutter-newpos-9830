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

Coloca el archivo provisto por el fabricante aquí:

```
android/libs/sdk.jar
```

Sin este archivo el plugin no compila.

## Aviso legal y de responsabilidad

- El `sdk.jar` y los paquetes `com.pos.device.*` y `com.secure.api.*` son
  **propiedad de Newpos / el fabricante del terminal**. **No** están cubiertos
  por la licencia MIT de este repositorio ni se distribuyen con él.
- **Obtenerlo y usarlo requiere licencia y autorización vigentes del
  fabricante.** Es responsabilidad exclusiva de quien compila o distribuye una
  aplicación basada en este plugin **contar con esos derechos** antes de
  incorporar el SDK, y cumplir los términos, restricciones de redistribución y
  la normativa aplicable (incluida la certificación PCI cuando corresponda).
- Este proyecto es únicamente un **envoltorio** de código abierto: no concede
  ningún derecho sobre el SDK del fabricante, no lo redistribuye y **no asume
  responsabilidad alguna** por su obtención, licenciamiento o uso. El software
  se entrega «TAL CUAL», sin garantías de ningún tipo (ver [`LICENSE`](../../LICENSE)).
