# SDK de firmware Newpos

Este plugin compila contra el SDK de plataforma del terminal Newpos
(`com.pos.device.*`, distribuido por el fabricante como `sdk.jar`).

- El `.jar` **no se versiona** en este repositorio (es propietario de Newpos).
- Se enlaza como `compileOnly`: el firmware del terminal provee las clases en
  tiempo de ejecución vía `<uses-library android:name="com.pos.device" />`.

## Para compilar

Coloca el archivo provisto por Newpos aquí:

```
android/libs/sdk.jar
```

Sin este archivo el plugin no compila. Distribuirlo requiere confirmar los
términos de licencia/redistribución con Newpos.
