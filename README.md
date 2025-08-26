# PHP Wrapper para múltiples versiones (Windows)

[![estado](https://img.shields.io/badge/status-ready-brightgreen.svg)](https://example.com) [![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Este repositorio contiene un pequeño "wrapper" para Windows que te permite ejecutar la versión de PHP que quieras según un archivo `.php-version` colocado en el directorio del proyecto (o en un padre). Es útil cuando trabajas con varios proyectos que usan distintas instalaciones de PHP (WAMP, XAMPP, instalaciones locales, etc.).

## Resumen rápido

- Coloca `php.cmd` en una carpeta que esté en tu PATH (o usa la carpeta donde está el wrapper directamente).
- Crea un archivo `.php-version` con la ruta al binario PHP deseado (o a la carpeta que contiene `php.exe`).
- Ejecuta `php -v`, `php -m` o cualquier comando `php` normalmente; el wrapper invocará el binario indicado.

## Contenido del repositorio

- `php.cmd` — wrapper batch (Windows) — recomendado para uso normal.
- `php-wrapper.ps1` — alternativa PowerShell (renombrada para evitar conflictos con `php` en PowerShell).
- `.php-version` — ejemplo de archivo que indica qué binario usar.

## Formato de `.php-version`

- Ruta absoluta al binario PHP, por ejemplo:
  `C:\wamp64\bin\php\php8.3.24\php.exe`
- Ruta absoluta a la carpeta que contiene `php.exe`, por ejemplo:
  `C:\wamp64\bin\php\php8.3.24\`
- Ruta relativa (se resuelve respecto al directorio donde está `.php-version`), por ejemplo:
  `..\tools\php\php.exe`
- Si no existe `.php-version`, el wrapper usará un fallback definido en `php.cmd` (`C:\php83\php.exe` por defecto). Edita `php.cmd` para cambiar el fallback.

## Instalación (paso a paso para usuarios inexpertos)

1. Copia la carpeta del wrapper (la que contiene `php.cmd`) a una ubicación del sistema o mantenla en un lugar fijo.

2. Añade la carpeta al PATH del sistema (opcional, para poder escribir `php` desde cualquier carpeta):

   - Abrir "Editar las variables de entorno del sistema" → Variables de entorno → seleccionar `Path` en variables de usuario o del sistema → Editar → Nuevo → pegar la ruta (por ejemplo `C:\php-wraper`) → Aceptar.

   - Nota: después de editar el PATH, abre una nueva ventana de PowerShell o cmd para que los cambios tomen efecto.

3. Crear `.php-version` dentro de tu proyecto (o en `C:\php-wraper` para pruebas) con el contenido adecuado. Ejemplos:

   - Ruta absoluta al exe:
     `C:\wamp64\bin\php\php8.3.24\php.exe`

   - Ruta a carpeta (el wrapper buscará `php.exe` dentro de la carpeta):
     `C:\wamp64\bin\php\php8.3.24\`

   - Ruta relativa (resuelta respecto al archivo `.php-version`):
     `..\tools\php\php.exe`

4. Probar desde una nueva terminal (muy importante abrir nueva terminal tras cambiar PATH):

   ```powershell
   php -v
   php -m
   ```

   Deberías ver la versión de PHP y la lista de módulos; si ves un error, revisa la sección "Solución de problemas" abajo.

## Cómo funciona por detrás (breve)

- El `php.cmd` busca un archivo `.php-version` en el directorio actual y sube por los directorios padres hasta encontrarlo o llegar a la raíz.
- Si encuentra `.php-version`, intenta resolver la ruta (absoluta o relativa). Si apunta a una carpeta, busca `php.exe` dentro.
- Si no encuentra nada usa un `fallback` (configurable en `php.cmd`).

## Solución de problemas (FAQs para usuarios inexpertos)

- Q: "Ejecuté `php -v` y no pasa nada / se queda pegado"
  - A: Abre una nueva terminal (si acabas de modificar el PATH). Comprueba si existe un archivo `php.ps1` en la carpeta del wrapper — PowerShell ejecuta `.ps1` por su nombre y esto puede provocar conflictos. Si ves `php.ps1`, renómbralo o bórralo. En este proyecto el PowerShell wrapper se llamó `php-wrapper.ps1` para evitar ese conflicto.

### Ejemplo de configuración exacto (flujo que usaste)

Si configuraste el wrapper de esta manera — copiaste la carpeta del wrapper a `C:\`, luego añadiste esa carpeta al PATH global y creaste un archivo `.php-version` en el proyecto apuntando a la ruta del binario — esto es exactamente lo que hiciste y cómo funciona:

1. Copiaste la carpeta (la que contiene `php.cmd`) a `C:\php-wraper` (o similar) en el disco C:

2. Abriste "Editar las variables de entorno del sistema" y añadiste `C:\php-wraper` al PATH del sistema (esto hace que al escribir `php` en cualquier terminal Windows se busque primero en esa carpeta).

3. En el proyecto donde quieres usar otra versión, creaste un archivo `.php-version` con la ruta completa al binario PHP que quieres usar, por ejemplo:

  `C:\wamp64\bin\php\php8.3.24\php.exe`

  o si apuntas a la carpeta:

  `C:\wamp64\bin\php\php8.3.24\`

4. Abriste una nueva terminal (muy importante) y ejecutaste:

  ```powershell
  php -v
  ```

  - El wrapper (`php.cmd` en `C:\php-wraper`) busca el archivo `.php-version` en el directorio actual del proyecto (donde ejecutaste el comando) y, si existe, invoca el binario que pusiste en el archivo.
  - Si no encuentra `.php-version`, usa el fallback que está configurado en `php.cmd`.

### Fallback global: archivo `.php-default`

Si quieres definir una versión por defecto global (que se use cuando no haya `.php-version` en el proyecto), crea un archivo llamado `.php-default` dentro de la carpeta del wrapper (por ejemplo `C:\php-wraper\.php-default`) y escribe en su interior la ruta completa al binario PHP que desees utilizar.

Ejemplo (`C:\php-wraper\.php-default`):

```
C:\wampnew64\bin\php\php7.4.33\php.exe
```

El wrapper leerá `.php-default` y usará esa ruta como fallback. Si `.php-default` no existe, se usará el valor hardcodeado dentro de `php.cmd`.

Este flujo es correcto y es la forma recomendada para usar distintas versiones por proyecto sin tocar la instalación global de PHP.

- Q: "Mi `php -v` usa otra instalación de PHP"
  - A: Ejecuta en PowerShell:
    ```powershell
    Get-Command php -All
    where.exe php
    ```
  - El primer resultado es el que PowerShell tiene registrado; `where.exe` muestra el orden en PATH. Asegúrate de que la carpeta con `php.cmd` esté antes de otras en el PATH si quieres que el wrapper tenga prioridad.

- Q: "Qué pongo en `.php-version` si tengo una instalación en WAMP?"
  - A: Puedes pegar la ruta al php.exe de WAMP, por ejemplo:
    `C:\wamp64\bin\php\php8.3.24\php.exe`

- Q: "Quiero cambiar la versión por proyecto sin editar `.php-version` manualmente"
  - A: Puedo añadir un subcomando `php use <version>` que gestione symlinks o archivos `.php-version` automáticamente. Dime si quieres que lo implemente.

## Tips y notas finales

- Si prefieres usar sólo PowerShell, podemos simplificar y dejar sólo `php-wrapper.ps1` y eliminar `php.cmd`, pero debes saber que PowerShell ejecuta scripts `.ps1` por nombre (puede provocar confusiones).
- Si compartes este wrapper con otros usuarios, recomienda que añadan la carpeta al PATH y que no exista `php.ps1` con el mismo nombre en PATH.

## Contacto / Ayuda

- Si quieres que te automatice la instalación (añadir al PATH automáticamente) o que implemente el comando `php use`, dímelo y lo preparo.

---
Documento generado automáticamente por el asistente de mantenimiento del wrapper.
