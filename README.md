# dart_realtime_game

An example of using Dart to build a realtime game.

Uses Dart for the full stack, shares code between client and server.

Uses a Entity Component System both for managing the game as well as
for network transport.

I did not (yet) implement client interpolation or speculation, so the
client only updates on server update pushes (currently 10 times per second).

Currently uses PlayCanvas for rendering through a Dart wrapper.

# Usage

## Setup
```
dart pub global activate webdev
dart pub global activate melos
```

## Developing locally
```
melos bootstrap # runs pub get for all packages

cd packages/server
dart run bin/serve.dart


cd packages/client
webdev serve
```

I typically run the server from the terminal and the client from VS Code.

## Building docker files locally

```
docker build -f .\dockerfiles\frontend.Dockerfile -t frontend . 
docker build -f .\dockerfiles\backend.Dockerfile -t backend .
```


# Next
* Abilities

How do do abilities?
When a button is pressed, an Action is sent to the server.
Action is added to the queue of actions to be processed
Action starts cooldown timer on the ability
Action is processed by the server
Action generates effects
Effects can generate entities.

Is everything just buffs?
Buffs are just timed effects associated with entities.
To compute any value you need to include effects of all buffs?

How do buffs relate to components?  Can you have multiple of the same component
for a given entity? Presuably yes.  So buffs are just components that are
timed and can be added and removed.

So to look up entity is a BuffedEntity, which includes all the buffs?



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
* Make it possible to interact between entities (e.g. attacks? collisions).
* Abitilies triggered by keys/buttons.
* Pickups/buffs which change something.
* Add database to hold server state.
* Make rendering fancier (e.g. walk cycle)
* Add background tiles (like forest)

# Inspirations
* https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html
* https://docs.unity3d.com/Packages/com.unity.entities@0.51/manual/index.html
* https://github.com/flame-engine/oxygen