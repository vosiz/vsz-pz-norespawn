# No Indoor Respawn
A Project Zomboid (Build 42) mod that stops zombies from appearing out of thin air inside rooms you have already explored, when zombie respawn is turned off.
## Motivation
With respawn off, you can still log in and find zombies inside your base, behind doors that never opened. This is not respawn. The game "populates" a building the first time someone sees it and remembers that per room and per chunk. The per-chunk record stores rooms by their index in the map files, and that index shifts whenever a game update changes the map. After an update, the game thinks parts of rooms you cleared long ago were never populated and fills them again on chunk load. It only does that on floors within one level of a connected player, so the problem can show up days after the update.
This mod is a temporary fix until the game handles it itself. MIT, use it however you like.
## Requirements
- Project Zomboid Build 42 (tested on 42.22.2)
- Runs on the server side: singleplayer, hosted and dedicated servers
## Bug tracker
No tracked issues. Report problems in [GitHub issues](https://github.com/vosiz/vsz-pz-norespawn/issues).
## Features
See [Roadmap](#roadmap).
## Roadmap
- [x] Remove zombies re-spawned on chunk load in explored rooms
- [x] Fill in missing "already populated" marks for explored rooms
- [x] Only active while zombie respawn is off
- [ ] Steam Workshop release
## Setup
Until the Workshop release, install it manually: copy `Contents/mods/NoIndoorRespawn` into your `Zomboid/mods` folder and add `NoIndoorRespawn` to the server's mod list. The server log shows a `[NoIndoorRespawn]` line for every zombie the mod removes.
