# shimmer2
 Attempt #2 at playing with full-stack realtime Dart.

# TODO
* Make rendering layer interpolate from GameState.
* Prediction logic should only predict on server ticks, not interpolate.
* Remove all uses of DateTime.now().
* Move clientTime to Duration.
* Only time clientTime can be accessed is through tick callback elapsed.
* Make WebSockets reconnect automatically.
* Draw animation on mouse click.
* Add ability to damage.
* Fix rendering to draw centered around position.
* Ability to set a color and name.
* Attacks/missiles.
* Attakcing automatically on proximity.
* Abitilies triggered by keys/buttons.
* Pickups/buffs which change something.
* Add database to hold server state.
* Make rendering fancier (e.g. walk cycle)
* Add background tiles (like forest)
* Switch to 3d frontend.


# Issues
- We leak PhysicsComponents on hot-restart.
- Make server only do something when clients are connected?

# References
https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html


# Usage

# Developing locally
```
melos bootstrap # runs pub get for all packages

cd packages/shimmer2_server
dart run bin/serve.dart


cd packages/shimmer2_client
flutter run
```

I typically run the server from the terminal and the client from VS Code.

# Building docker files locally

```
docker build -f .\dockerfiles\frontend.Dockerfile -t frontend . 
docker build -f .\dockerfiles\backend.Dockerfile -t backend .
```