# shimmer2
 Attempt #2 at playing with full-stack realtime Dart.

# TODO
* Replace GameState with Entity Component System.
* Replace Flame with canvas.
* Move to doubles for entity positions.
* Make rendering layer interpolate from GameState.
* Remove all uses of DateTime.now().
* Move serverTime to ticks.
* Move clientTime to Duration.
* Only time clientTime can be accessed is through tick callback elapsed.

# MVP
- Make docker container
- Push to somewhere.

# Issues
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