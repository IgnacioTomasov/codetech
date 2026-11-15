# Arquitectura

La idea es separar:

* states/ → cómo se juega/visualiza
* entities/ → actores del mundo
* core/ → reglas y estado persistente del juego

Ideas para core

Estado actual: `clock` y `stats` viven dentro de `game_session.lua`;
`save_system` ya está implementado; `event_bus` aún no existe.

core/
├── game_session.lua  ✓ (flags, stats, clock y player)
├── clock.lua         (por separar de game_session)
├── stats.lua         (por separar de game_session)
├── save_system.lua   ✓ (guarda/restaura la sesión)
└── event_bus.lua     (pendiente)

## Arquitectura de Flags

- Las flags representan estado persistente del mundo.
- Las flags describen permisos, progreso o hechos ocurridos.
- Las flags NO representan estados transitorios ni comportamiento físico.

Ejemplos:
    office_access
    tutorial_completed
    email_hr_read

GameSession es el punto único de acceso:

    session:setFlag(...)
    session:getFlag(...)
    session:isFlagEnabled(...)

Patrón principal:

    Evento
        ↓
    Flag
        ↓
    Entidad consulta flag
        ↓
    Entidad ejecuta comportamiento

Principio fundamental:

    Las flags controlan autorización.
    Las entidades controlan comportamiento.

Ejemplo:

    contract_signed = true

significa:

    El jugador puede usar las puertas del piso.

NO significa:

    La puerta está abierta.

La puerta decide por sí misma cuándo abrirse, cerrarse, reproducir audio, mover colliders o animarse.

Nota de implementación: en la actualidad las puertas
(src/entities/doors.lua) comprueban `contract_signed`, no `office_access`.
Ambas flags se activan juntas al firmar el contrato.

Evitar:

    Evento -> manipula directamente entidades

Preferir:

    Evento -> modifica flags
    Entidades -> reaccionan consultando flags


# Sistema de diálogos

## Filosofía

Los diálogos son contenido separado del motor del videojuego. Se organizan en páginas, ofrecen opciones y, según la opción seleccionada, pueden modificar flags persistentes y redirigir hacia otro diálogo. Desde este punto de vista, los diálogos forman un grafo dirigido, donde cada nodo representa una conversación y cada opción puede conducir a otro nodo.

Ejemplo  para dialogo de control de acceso (src/content/la_llegada/control_acceso.lua):

control_acceso:contract_intro
            │
    ┌───────┴────────┐
    │                │
 Aceptar         Rechazar
 (flags)             │
    │                ▼
    ▼          contract_reject
 Fin (flags)          │
                      ▼
                     Fin


El flujo del sistema es:

```
Trigger
    ↓
ShowDialogAction
    ↓
TextBoxState
    ↓
DialogRepository
    ↓
Contenido (src/content)
    ↓
TextFormatter
    ↓
Pantalla
```

El objetivo es que el contenido narrativo permanezca completamente desacoplado del motor del juego.

Los diálogos no deben contener lógica de ejecución.

Las decisiones del jugador modifican únicamente **flags persistentes** y el resto del juego reacciona consultando esas flags.

---

## Organización del contenido

Todo el contenido narrativo debe almacenarse bajo:

```
src/content/
```

Se recomienda organizar el contenido siguiendo la estructura narrativa del juego.

Ejemplo:

```
src/content/
    la_llegada/
        control_acceso.lua
        recepcion.lua

    emails/
        onboarding.lua
```

Evitar archivos gigantes. Cada archivo debe contener únicamente conversaciones relacionadas entre sí.

Nota: el contenido de los emails vive hoy en `src/core/email/email_repository.lua`.
Si los emails pasan a ser narrativo, migrarlo a `src/content/`.

---

## Crear un diálogo

Cada archivo retorna una tabla cuyos elementos representan diálogos independientes.

```lua
return {

    contract_intro = {

        pages = {

            {
                text = "Bienvenido a {company_name}."
            },

            {
                text = "¿Deseas firmar?",

                options = {

                    {
                        text = "Aceptar",

                        flags = {
                            contract_signed = true,
                            office_access = true,
                        }

                    },

                    {
                        text = "Rechazar",

                        flags = {
                            contract_rejected = true,
                        },

                        gotoDialog =
                            "la_llegada/control_acceso:contract_reject"

                    }

                }

            }

        }

    }

}
```

---

## Abrir un diálogo

Los diálogos se abren mediante `ShowDialogAction`.

```lua
ShowDialogAction:create(
    session,
    "la_llegada/control_acceso:contract_intro"
)
```

El identificador utiliza el formato:

```
carpeta/archivo:id_dialogo
```

Ejemplo:

```
la_llegada/control_acceso:contract_intro
```

---

## Estructura de una página

Una página puede contener únicamente texto:

```lua
{
    text = "Bienvenido."
}
```

O bien texto y opciones:

```lua
{
    text = "¿Deseas continuar?",

    options = {
        {
            text = "Sí"
        },
        {
            text = "No"
        }
    }
}
```

---

## Opciones

Cada opción puede contener:

- `text`
- `flags`
- `gotoDialog`

Ejemplo:

```lua
{
    text = "Aceptar",

    flags = {
        office_access = true,
        tutorial_completed = true,
    }
}
```

Las flags son aplicadas automáticamente por el motor.

---

## Navegación entre diálogos

Una opción puede abrir otro diálogo mediante:

```lua
gotoDialog = "la_llegada/control_acceso:contract_details"
```

Cuando existe `gotoDialog`:

- el diálogo actual es reemplazado;
- el `TextBoxState` permanece abierto;
- se reinicia la conversación en la primera página del nuevo diálogo;
- no se crea un nuevo estado.

También puede declararse a nivel de página (`page.gotoDialog`): se ejecuta
al confirmar la última página del diálogo actual.

Esto permite construir conversaciones ramificadas y convergentes.

---

## Placeholders

Los textos pueden contener placeholders.

```lua
text = "Bienvenido {player_name}."
```

Durante el renderizado serán reemplazados automáticamente.

Los placeholders son administrados por:

```
src/content/text_formatter.lua
```

---

## Agregar nuevos placeholders

Los placeholders pueden declararse directamente dentro de `text_formatter.lua`.

Ejemplo:

```lua
player_name = function(session)
    return session.player and session.player.name or "Jugador"
end
```

También pueden registrarse dinámicamente.

```lua
TextFormatter:register(
    "current_day",
    function(session)
        return session.clock.day
    end
)
```

Todos los placeholders deben obtener su información desde `GameSession`.

Ejemplo:

```lua
self.player = {
    name = "Jugador"
}
```

---

## Principios

- Los diálogos contienen únicamente contenido.
- Las flags representan estado persistente.
- Las entidades deciden su comportamiento consultando flags.
- Las acciones (`ShowDialogAction`, `SetFlagAction`, etc.) son reutilizables.
- El contenido narrativo nunca debe vivir dentro de acciones, estados o triggers.
- Utilizar `gotoDialog` para reutilizar conversaciones y evitar duplicar texto.
- Organizar los diálogos siguiendo la estructura narrativa del juego.
- Mantener el contenido declarativo. Si una conversación necesita ejecutar lógica compleja, esa lógica debe implementarse mediante acciones y/o eventos, nunca dentro del archivo de contenido.


## Guardado de la sesión

`src/core/save_system.lua` serializa `GameSession` (flags, stats, clock, player)
a texto Lua y lo restaura sobre una sesión nueva o existente.

    SaveSystem.guardar(session)     -- escribe guardado.lua
    SaveSystem.cargarEn(session)    -- restaura en la sesión dada (limpia flags previas)
    SaveSystem.existeGuardado()     -- ¿hay guardado?

En el juego: "Guardar partida" desde la pausa y "Continuar" en el menú
(si existe guardado). El archivo se escribe en la carpeta de guardado de
LÖVE (`identity = codetech` en conf.lua). No se guarda la posición del
jugador en el mapa, solo el estado persistente de la sesión.

---

## Ejecución de pruebas

Desde la raíz del repositorio:

```sh
lua tests/run.lua         # pruebas unitarias del motor
lua tests/validador.lua   # consistencia de diálogos, triggers y flags
```

Ambos comandos terminan con código distinto de 0 si algo falla.
El detalle de los comandos de verificación está en `AGENTS.md`.