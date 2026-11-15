# AGENTS.md — CodeTech (juego en LÖVE 2D / Lua)

## Cómo ejecutar y verificar

- Es un juego de LÖVE (Love2D). No hay build, lint ni CI. La verificación tiene dos partes:
  - Pruebas y validación de contenido (Lua puro, sin LÖVE; requiere `lua`): `lua tests/run.lua` y `lua tests/validador.lua`. Ambos salen con código distinto de 0 si hay fallos.
  - Ejecución visual del juego desde la raíz del repo: `love .`.
- `tests/run.lua` ejecuta automáticamente todos los `tests/*_test.lua` (cada archivo retorna una tabla `{ nombre_prueba = función }`; helpers disponibles: `igual(actual, esperado)`, `verdad(cond)`, `falso(cond)`).
- El validador comprueba: estructura de diálogos en `src/content/`, que cada `gotoDialog` y cada `ShowDialogAction` resuelva contra `DialogRepository`, y que toda flag requerida (puertas en `npc.lua`, `TriggerArea` con `disableFlag`) se defina en alguna parte (opciones de diálogo, `SetFlagAction` o defaults de `GameSession`). **Ejecutarlo tras cualquier cambio de contenido o triggers**: es la única forma de detectar ids/flags mal escritos sin jugar.
- La ventana es 1280x720 (`conf.lua`).
- Atajo de debug: en `main.lua`, `START_DIALOG` permite abrir cualquier diálogo al arrancar (formato `"carpeta/archivo:id_dialogo"`), útil para probar contenido nuevo sin jugar hasta llegar a él.
- Si un error de Lua rompe el juego, aparecerá la pantalla de error de LÖVE; los `assert` de `DialogRepository` son la primera pista típica (id de diálogo mal escrito).

## Arquitectura

- `main.lua` crea **una única `GameSession`** (`src/core/game_session.lua`) y se la pasa a todos los estados. Todo el estado del juego vive ahí: `flags`, `stats` (ansiedad, prestigio, energia), `clock` (day/hour/minute) y `player`.
- **No hay guardado**: `GameSession` solo vive en memoria; al cerrar el juego se pierde. `save_system.lua` del Readme aún no existe.
- `StateManager` (`src/managers/state_manager.lua`) usa una pila:
  - `switch` vacía la pila; `push` apila (usado para overlays: textbox, pause, email).
  - `load` se ejecuta **una sola vez** por estado (flag `loaded`); `enter` en cada push.
  - Un estado con `isOverlay = true` hace que el estado de abajo se siga dibujando (así funciona el textbox sobre el juego).
- Patrón flags (ver Readme): evento → modifica flags vía `session:setFlag(...)` → entidades consultan con `isFlagEnabled` y deciden su comportamiento. No manipular entidades directamente desde eventos. Ejemplo: `Door` (`src/entities/doors.lua`) se abre sola si `requiredFlag` está activo y el jugador está cerca.
- **Guardado** (`src/core/save_system.lua`): serializa `GameSession` (flags/stats/clock/player) a un chunk Lua en `guardado.lua` (carpeta de guardado de LÖVE, `identity = "codetech"` en `conf.lua`). `SaveSystem.aplicar/cargarEn` limpia las flags previas de la sesión antes de restaurar. **No guarda la posición del jugador en el mapa**, solo el estado persistente. Integrado en la pausa ("Guardar partida") y el menú ("Continuar" solo aparece si hay guardado).

## Contenido narrativo (diálogos)

- Todo en `src/content/`, organizado por arco narrativo. Los archivos son **datos declarativos**: tablas con `pages`, `options`, `flags`, `gotoDialog`. Nunca lógica de ejecución dentro del contenido.
- Id de diálogo: `"carpeta/archivo:id"` (ej. `la_llegada/control_acceso:contract_intro`). `DialogRepository` (`src/content/dialogs.lua`) resuelve el `require` y cachea.
- Placeholders `{nombre}` se resuelven en `src/content/text_formatter.lua`; los resolvers reciben `session` y deben leer todo desde ahí.
- Se abre un diálogo con `ShowDialogAction:create(session, id)` (devuelve una función/closure, no un objeto).

## Mundo, mapa y físicas

- Mapa actual: `maps/office_floor_14/floor_14.lua`. STI **carga el `.lua` exportado desde Tiled**, no el `.tmx`: tras editar un mapa hay que reexportarlo o los cambios no aparecen.
- Colisiones: mundo `bump` (`bump.newWorld(64)`). `collisions.solve` crea colliders desde las custom properties de los tiles: `solid` (booleana) y ajustes `l_wall_solid_px` / `r_wall_solid_px` para paredes parciales.
- En `game:draw()` cada capa del mapa se dibuja explícitamente por nombre (`Piso`, `Paredes-Puertas`, `Ventanas`, `Mesas`, `Sillas`, `Adornos`): una capa nueva en Tiled no se verá hasta añadirla ahí (y marcar sólidos si corresponde).
- Los triggers están **hardcodeados en `src/triggers/office_triggers.lua`** (no en Tiled), con coordenadas en tiles de 32px. `TriggerArea` dispara solo al entrar (una vez hasta salir, opcional `disableFlag`); `InteractionArea` requiere pulsar espacio con el jugador dentro.
- `character.new(x, y, w, h, spriteOffsetX, spriteOffsetY, speed, spriteName)`: `w/h` son del collider, los offsets mueven el sprite respecto al collider. El grid de anim8 en `character.lua` asume sprite sheet de **4 columnas y 1 fila** (hardcode, ver comentario).

## Audio

- `AudioManager` (`src/managers/audio_manager.lua`) carga cada archivo manualmente en `load()`: para un sonido nuevo hay que añadir una entrada; la clave (`playSfx("accept")`) no es el nombre del archivo. Música con `"stream"` y loop, sfx con `"static"` (se reproduce con `:clone()`).

## Gotchas conocidos

- `src/core/email/email_actions.lua` usa `session.time.hour`, pero la sesión define `clock`. Al tocar ese archivo, usar `session.clock` (bug latente).
- El email state (`e` en juego) lee `EmailRepository` directamente; sus acciones aún no están cableadas.

## Convenciones del repo

- Todo en español: comentarios, strings del juego, mensajes de commit (en minúscula, sin conventional commits).
- `src/version.lua`: `minor.fix` — minor sube al pasar a master, fix con cada commit.
- Controles en juego: flechas mover, espacio correr (x2) / interactuar, `return` pausa, `e` email, `escape` cerrar email.
