# Arquitectura

La idea es separar:

* states/ → cómo se juega/visualiza
* entities/ → actores del mundo
* core/ → reglas y estado persistente del juego

Ideas para core

core/
├── game_session.lua
├── clock.lua
├── stats.lua
├── save_system.lua
└── event_bus.lua



Arquitectura de Flags - Codetech

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

    office_access = true

significa:

    El jugador puede usar la puerta.

NO significa:

    La puerta está abierta.

La puerta decide por sí misma cuándo abrirse, cerrarse, reproducir audio, mover colliders o animarse.

Evitar:

    Evento -> manipula directamente entidades

Preferir:

    Evento -> modifica flags
    Entidades -> reaccionan consultando flags
