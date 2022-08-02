# dart_realtime_game

An example of using Dart and Flutter to build a realtime game.

Uses Dart for the full stack, shares code between client and server.

Uses a Entity Component System both for managing the game as well as
for network transport.

I did not (yet) implement client interpolation or speculation, so the
client only updates on server update pushes (currently 10 times per second).

This does not use any "game" frameworks, just draws directly to canvas.
Most game frameworks I've found do not separate state from rendering,
so I chose to write my own (very simple) rendering layer.

# Usage

## Developing locally
```
melos bootstrap # runs pub get for all packages

cd packages/server
dart run bin/serve.dart


cd packages/client
flutter run
```

I typically run the server from the terminal and the client from VS Code.

## Building docker files locally

```
docker build -f .\dockerfiles\frontend.Dockerfile -t frontend . 
docker build -f .\dockerfiles\backend.Dockerfile -t backend .
```

# Known issues
- Server leaks 2 PhysicsComponents on hot-restart.
- Server leaks player connections when players drop (leaving zombies).
- Server spins even when no players are connected.

## Things left on my TODO (no further development currently planned)
* Make rendering layer interpolate from GameState.
* Remove all uses of DateTime.now() and move clientTime to Duration.
* Only time clientTime can be accessed is through tick callback elapsed.
* Make WebSockets reconnect automatically.
* Draw animation on mouse click.
* Add ability to have players damage each other.
* Fix rendering to draw centered around position.
* Ability to set a color and name.
* Abitilies triggered by keys/buttons.
* Pickups/buffs which change something.
* Add database to hold server state.
* Make rendering fancier (e.g. walk cycle)
* Add background tiles (like forest)
* Switch to 3d frontend.

# Inspirations
* https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html
* https://docs.unity3d.com/Packages/com.unity.entities@0.51/manual/index.html
* https://github.com/flame-engine/oxygen