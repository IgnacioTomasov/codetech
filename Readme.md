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
