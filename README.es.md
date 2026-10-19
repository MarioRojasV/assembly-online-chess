# Ajedrez en línea en ensamblador (x86 / Irvine32)

Juego de ajedrez para dos jugadores en la consola de Windows. Toda la lógica del juego y la interfaz están escritas en **ensamblador x86 (MASM) con la librería Irvine32**. Un pequeño **script de Python** sincroniza el estado de la partida entre dos computadoras a través de **Firebase Firestore**, de modo que cada jugador puede jugar desde su propia máquina.

> Proyecto desarrollado para el curso **Arquitectura de Computadores** del **Tecnológico de Costa Rica (TEC)**, II semestre de 2024.

**Autores**

- Mario Andrés Rojas Varela
- Sebastián Josué Sandí Blanco

**Demo:** _(agregar aquí el enlace al video o un GIF de la partida)_

---

## Tabla de contenidos

1. [¿De qué trata el proyecto?](#de-qué-trata-el-proyecto)
2. [Características](#características)
3. [Cómo funciona](#cómo-funciona)
4. [Requisitos](#requisitos)
5. [Configuración de Firebase](#configuración-de-firebase)
6. [Compilar el ejecutable](#compilar-el-ejecutable)
7. [Cómo jugar](#cómo-jugar)
8. [Controles y reglas implementadas](#controles-y-reglas-implementadas)
9. [Solución de problemas](#solución-de-problemas)
10. [Limitaciones conocidas](#limitaciones-conocidas)
11. [Estructura del repositorio](#estructura-del-repositorio)
12. [Seguridad](#seguridad)
13. [Créditos](#créditos)

---

## ¿De qué trata el proyecto?

El objetivo del curso era construir una aplicación completa programada a bajo nivel. Este proyecto implementa un ajedrez jugable en red donde:

- El **tablero, las piezas, los menús y la validación de movimientos** viven enteramente en ensamblador, trabajando directamente con registros, memoria, estructuras y llamadas a la API de Windows.
- La **comunicación en red** se delega a un puente en Python, porque el ensamblador del proyecto solo sabe leer y escribir un archivo de texto local.

## Características

- Interfaz de consola con pantalla de inicio y menú principal (nueva partida, historial, configuración y salida).
- Tablero dibujado con colores, con orientación propia para cada jugador (las blancas ven el tablero desde abajo y las negras desde su lado).
- Piezas dibujadas con **símbolos Unicode de ajedrez** (♚ ♛ ♜ ♝ ♞ ♙). Cada bando se distingue por color.
- Personalización de colores del tablero y de las piezas, manualmente o con combinaciones predefinidas.
- Nickname de cada jugador.
- Validación de movimientos por tipo de pieza: peón, torre, caballo, alfil, reina y rey.
- Detección de piezas en el camino (torre, alfil y reina no saltan piezas) y captura de piezas rivales.
- Partida en línea entre dos computadoras mediante Firestore.

## Cómo funciona

```
 Jugador 1 (PC A)                                         Jugador 2 (PC B)
┌─────────────────┐                                     ┌─────────────────┐
│  Ajedrez.exe    │                                     │  Ajedrez.exe    │
│  (ensamblador)  │                                     │  (ensamblador)  │
└───────┬─────────┘                                     └─────────┬───────┘
        │ lee / escribe                                           │ lee / escribe
   ┌────▼──────────┐                                       ┌──────▼────────┐
   │ GameFile.txt  │                                       │ GameFile.txt  │
   └────┬──────────┘                                       └──────┬────────┘
        │ sincroniza                                              │ sincroniza
┌───────▼─────────┐        ┌───────────────────────┐      ┌───────▼─────────┐
│FileDownloader.py│◄──────►│  Firebase Firestore   │◄────►│FileDownloader.py│
└─────────────────┘        │ ajedrez/GameFile      │      └─────────────────┘
                           └───────────────────────┘
```

1. El ejecutable guarda el estado de la partida en `GameFile.txt` cada vez que el jugador mueve y luego espera ("Waiting for opponent's response").
2. `FileDownloader.py` revisa cada 3 segundos si el archivo local cambió. Si cambió, lo sube a Firestore (documento `GameFile` de la colección `ajedrez`).
3. En la otra computadora, su propia copia de `FileDownloader.py` detecta que el documento remoto cambió y reescribe su `GameFile.txt` local.
4. El ejecutable del otro jugador detecta que el archivo cambió, carga las piezas y le toca mover.

### Formato de `GameFile.txt`

Es texto plano. En la versión base del proyecto el formato es:

```
<estado><turno>*<pieza><color><columna><fila>/<pieza><color><columna><fila>/ ... %
```

| Parte | Significado |
|---|---|
| Primer carácter | Estado del juego. Un `5` indica que la partida terminó, y los dos scripts de Python se cierran. |
| Segundo carácter | Indica de quién es el turno. Se usa también para asignar los colores: quien encuentra `2` al iniciar juega con negras. |
| `*` | Separador de la cabecera. |
| Cada pieza (5 bytes) | Tipo (`K`, `Q`, `R`, `B`, `N`, `P`), color (`w`/`b`), columna (`A`-`H`), fila (`1`-`8`) y el separador `/`. |
| `%` | Fin del archivo. |

> Si cambias el formato en el ensamblador, el script de Python no necesita ajustes: solo mueve bytes sin interpretarlos.

### Quién juega con blancas

No hay un rol asignado de antemano. **Quien crea la partida primero juega con blancas.** Al crear la partida, el ejecutable escribe `02%` en `GameFile.txt`. Ese archivo llega al otro jugador por Firebase, y cuando el segundo ejecutable lo encuentra, se asigna las negras.

Por eso el **orden de arranque importa** (ver [Cómo jugar](#cómo-jugar)).

## Requisitos

### Para jugar (cada jugador)

| Requisito | Detalle |
|---|---|
| Sistema operativo | Windows 10 u 11 |
| Terminal | **Windows Terminal** (recomendado). La consola clásica (CMD) no tiene fuentes con los símbolos de ajedrez y los muestra como cuadros con signo de pregunta. |
| Python | Python 3.8 o superior |
| Librería de Python | `firebase-admin` (`pip install firebase-admin`) |
| Firebase | Un proyecto con Firestore y una llave de cuenta de servicio (ver abajo) |
| Archivos | El `.exe`, `GameFile.txt`, `FileDownloader.py` y `serviceAccountKey.json`, **todos en la misma carpeta** |

Los dos jugadores deben usar **el mismo proyecto de Firebase**. Puedes probar todo en una sola computadora usando dos carpetas (`Jugador_1/` y `Jugador_2/`), cada una con su propia copia de los cuatro archivos.

### Para compilar (solo si vas a modificar el código)

- Visual Studio 2022 (Community es suficiente) con la carga de trabajo **Desarrollo para el escritorio con C++**, o las Build Tools de Visual Studio.
- La librería **Irvine32** de Kip Irvine, descargable desde [asmirvine.com](https://asmirvine.com), extraída en `C:\Irvine`.

## Configuración de Firebase

Se hace una sola vez, y los dos jugadores usan el mismo proyecto.

1. Entra a la [consola de Firebase](https://console.firebase.google.com) y crea un proyecto.
2. En **Build → Firestore Database** pulsa **Create database**. Elige cualquier región. Firestore tiene una capa gratuita suficiente para este proyecto.
3. En **Configuración del proyecto → Cuentas de servicio** pulsa **Generar nueva clave privada**. Se descarga un archivo `.json`.
4. Renombra ese archivo a **`serviceAccountKey.json`** y cópialo a la carpeta de cada jugador.
5. **Nunca subas ese archivo a un repositorio.** Está incluido en el `.gitignore`.

El script usa por defecto la colección `ajedrez` y el documento `GameFile`. Se pueden cambiar en la sección de configuración al inicio de `FileDownloader.py`.

### Detalle técnico importante de la sincronización

Firestore **no actualiza la fecha de modificación de un documento si se escribe exactamente el mismo contenido**. Como el primer archivo de cada partida (`02%`) es siempre idéntico al de la partida anterior, el script añade un campo `uploaded_at` con `firestore.SERVER_TIMESTAMP` en cada subida:

```python
result = doc_ref.set({'content': content, 'uploaded_at': firestore.SERVER_TIMESTAMP})
```

Sin ese campo, el segundo jugador nunca detectaría el cambio y ambos se quedarían esperando indefinidamente.

## Compilar el ejecutable

Si solo quieres jugar, usa el `.exe` precompilado de la sección *Releases* y salta este paso.

### Opción A: Visual Studio

1. Crea un **Proyecto vacío (C++)** y agrega el archivo `.asm` con *Agregar → Elemento existente*.
2. Clic derecho en el proyecto → **Personalizaciones de compilación...** → marca **masm**.
3. Clic derecho en el proyecto → **Propiedades**, con *Configuración: Todas las configuraciones* y *Plataforma: **Win32*** (32 bits, nunca x64):

| Dónde | Valor |
|---|---|
| Microsoft Macro Assembler → General → Include Paths | `C:\Irvine` |
| Vinculador → General → Directorios de bibliotecas adicionales | `C:\Irvine` |
| Vinculador → Entrada → Dependencias adicionales | `irvine32.lib;kernel32.lib;user32.lib` |
| Vinculador → Sistema → Subsistema | `Console` |
| Vinculador → Avanzado → Image Has Safe Exception Handlers | `No (/SAFESEH:NO)` |

4. Compila con **Ctrl+Mayús+B**. El `.exe` queda en la carpeta `Debug` de la solución.

> Si aparece el error **LNK1168** ("no se puede abrir para escritura"), el ejecutable anterior sigue corriendo. Ciérralo y vuelve a compilar.

### Opción B: línea de comandos

Desde el *x86 Native Tools Command Prompt for VS*:

```bat
ml /c /coff /Zi /I C:\Irvine main.asm
link /SUBSYSTEM:CONSOLE /SAFESEH:NO /LIBPATH:C:\Irvine main.obj irvine32.lib kernel32.lib user32.lib
```

### Nota sobre los símbolos de las piezas

Irvine32 imprime con la API ANSI de Windows y no soporta Unicode. Por eso las piezas se dibujan con `WriteConsoleW` (de `kernel32`), que recibe UTF-16. El procedimiento `printGlyph` recibe la letra de la pieza en `AL` y la traduce a su símbolo; el resto del juego (y el archivo `GameFile.txt`) sigue usando letras.

Detalles que vale la pena conocer:

- Los símbolos son más anchos que una celda de la consola. Para que el color de fondo cubra toda la pieza, `printGlyph` imprime el símbolo seguido de un espacio.
- El peón relleno (♟) se dibuja como emoji y no respeta el color. Se usa el peón de contorno (♙, U+2659), que sí lo respeta.

## Cómo jugar

El orden importa. Sigue estos pasos exactamente.

### Preparación (cada jugador)

1. Crea una carpeta con: el `.exe`, `GameFile.txt`, `FileDownloader.py` y `serviceAccountKey.json`.
2. Instala la dependencia: `pip install firebase-admin`
3. Deja `GameFile.txt` **vacío**.

### Iniciar una partida

1. **Los dos jugadores** abren una terminal (Windows Terminal) en su carpeta y ejecutan:
   ```
   python FileDownloader.py
   ```
   Espera a que ambos muestren que están esperando el primer movimiento. **Los dos scripts deben estar corriendo antes de crear la partida.**
2. **Jugador 1 (blancas):** ejecuta el `.exe`, elige **1. New Game** y escribe su nickname. Queda esperando al oponente.
3. **Jugador 2 (negras):** antes de abrir el `.exe`, comprueba que ya recibió la partida:
   ```
   type GameFile.txt
   ```
   Repite el comando hasta que muestre `02%`. **Solo entonces** ejecuta el `.exe`, elige **New Game** y escribe su nickname.
4. La partida comienza y mueve el Jugador 1.

> Si el Jugador 2 abre el `.exe` antes de que llegue `02%`, también se asigna las blancas y ambos se quedan esperando para siempre. Si pasa, reinicia todo.

### Entre partidas

- Cierra los dos `.exe` y los dos scripts (Ctrl+C).
- Deja `GameFile.txt` vacío en ambas carpetas y repite desde el paso 1.
- Al salir por la opción **4. Exit** se escribe el marcador de fin de partida (`5`) y los scripts se cierran solos.

## Controles y reglas implementadas

- Para mover, escribe la casilla de origen y luego la de destino en notación algebraica, por ejemplo `E2` y luego `E4`. El programa acepta letras de `A` a `H` en mayúscula y números del `1` al `8`.
- Si la casilla de origen está vacía o el movimiento no es válido, se muestra un mensaje en rojo y se vuelve a pedir el movimiento.
- Si el destino tiene una pieza propia, el movimiento se rechaza. Si tiene una pieza rival, se captura.
- Para elegir opciones en el menú, escribe el número y pulsa **Enter**.
- En **3. Settings** puedes cambiar los colores del tablero y de las piezas.

## Solución de problemas

| Síntoma | Causa y solución |
|---|---|
| Las piezas aparecen como cuadros con `?` | Estás usando el CMD clásico. Ejecuta el `.exe` desde **Windows Terminal**. Si persiste, cambia la fuente en *Configuración → Valores predeterminados → Apariencia* a Consolas o DejaVu Sans Mono. |
| Ambas ventanas se quedan en "Waiting for opponent's response" | El Jugador 2 abrió el `.exe` antes de recibir `02%`, o los scripts de Python no estaban corriendo antes de crear la partida. Cierra todo y repite el orden de [Cómo jugar](#cómo-jugar). |
| Un script de Python muestra `Sync error (will retry)` | Revisa que `serviceAccountKey.json` esté en la carpeta, que sea la misma llave de proyecto en ambos jugadores y que Firestore esté creada. |
| `No module named 'firebase_admin'` | Ejecuta `python -m pip install firebase-admin` (usa el mismo Python con el que corres el script). |
| El script se cierra solo | El archivo local empezó con `5` (fin de partida). Deja `GameFile.txt` vacío y vuelve a empezar. |
| LNK1168 al compilar | El `.exe` anterior sigue abierto. Ciérralo y recompila. |
| La pantalla de inicio o el tablero se ven desordenados | La ventana es demasiado pequeña. Ensánchala (el juego necesita unas 120 columnas). |
| Tras recompilar, siguen apareciendo letras en vez de símbolos | Estás ejecutando una copia vieja del `.exe`. Compilar no actualiza las copias en las carpetas de los jugadores: cópialo de nuevo a mano. |

## Limitaciones conocidas

- **No detecta jaque ni jaque mate.** El juego no avisa cuando un rey está en jaque ni termina la partida automáticamente; los jugadores deben ponerse de acuerdo y salir por el menú.
- No hay detección de tablas ni de fin de partida.
- La sincronización es por sondeo cada 3 segundos, así que hay un pequeño retraso entre jugada y jugada.
- Probado únicamente en Windows con Windows Terminal.
- El script usa una única partida compartida (un solo documento en Firestore), por lo que solo puede haber una partida a la vez por proyecto de Firebase.

## Estructura del repositorio

```
.
├── README.md
├── src/
│   └── main.asm                       # Lógica del juego e interfaz (MASM + Irvine32)
├── FileDownloader.py                  # Puente de sincronización con Firestore
├── GameFile.txt                       # Canal de comunicación (se deja vacío)
├── serviceAccountKey.example.json     # Plantilla con valores falsos
└── .gitignore                         # Excluye la llave real
```

_(Ajusta los nombres según cómo organices el repositorio.)_

## Seguridad

- `serviceAccountKey.json` da acceso administrativo a tu proyecto de Firebase. **No lo subas a Git.** Agrega esto al `.gitignore`:
  ```
  serviceAccountKey.json
  *firebase-adminsdk*.json
  ```
- Si alguna llave se llegó a publicar o a compartir, revócala en *Configuración del proyecto → Cuentas de servicio → Administrar permisos en Google Cloud* y genera una nueva. Si llegó a un commit, hay que limpiar el historial (por ejemplo con `git filter-repo`) o crear el repositorio de cero.

## Créditos

Proyecto 1 del curso **Arquitectura de Computadores**, Tecnológico de Costa Rica, II semestre de 2024.

- Mario Andrés Rojas Varela
- Sebastián Josué Sandí Blanco

Librería Irvine32: Kip Irvine, *Assembly Language for x86 Processors*.
