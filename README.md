# shimmer2
 Attempt #2 at playing with full-stack realtime Dart.

# TODO
* Make rendering layer interpolate from GameState.
* Prediction logic should only predict on server ticks, not interpolate.
* Remove all uses of DateTime.now().
* Move clientTime to Duration.
* Only time clientTime can be accessed is through tick callback elapsed.

# MVP
- Fix pushed container to work.

# Issues
- We leak PhysicsComponents on hot-restart.
- Do server transmissions need to be marked volatile?
- Make server only do something when clients are connected?
- VSC doesn't surface analyzer issues in shimmer2_shared code.

# Next
- Make it possible to set a color from the client.
- Make it possible to set a name from the client.

# Arch
- Server ticks at a fixed rate
- Client runs a copy of the server (predicter) tick.
- Client actions polled at a fixed rate and sent to both server and predicter.
- Client renders from predicter at current time.
- Packets from server update predicters previous times.
- Client uses further interpoloation between states to smooth animations?

# References
https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html


# Usage

# Building docker files


Building locally:

```
docker build -f .\dockerfiles\frontend.Dockerfile -t frontend . 
docker build -f .\dockerfiles\backend.Dockerfile -t backend .
```