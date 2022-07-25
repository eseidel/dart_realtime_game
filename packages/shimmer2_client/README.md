# shimmer2_client

Client side of shimmer example.

## MVP Goal
* Multiple players connected
* Auto-attacks
* Triggered Abitilies
* Pickups/buffs



- Server runs simulation
- Clients send input to server
- Clients run local speculative simulation.
- Every game tick, server sends update to clients.

## Action/Intention Visibility
* Clients can only see their own intentions.
* Server can see all intents, but does not store on Entities?
* Intentions have to be converted to "buffs" to be applied to Entities.
* Buffs have a duration and can render as animations.
* MOBs use a differnet intention system, which is globally visible?

## Pipeline

* Server entity logic
Inputs: GameState, Inputs, TimeDelta
* Client prediction logic
Uses same GameState logic as server.
Inputs: GameState, Input, TimeDelta
Inputs only change your player state.
But timedelta will affect all state.
* Client render
Productes render objects from GameState.

- Every frame client draws
- Client pulls current state from speculator.
- Client asks each entity to speculate to the closes ms?
- Render pipeline draws from speculated entity state?



# Questions
- How do we relate client and server time?
- Does tick rate need to be variable?  Yes server config.
- Do we just open a new "transaction" after every server update?


- Are displacement effects on the client or server?  e.g. when one entity pulls
another entity.  Maybe they're pre-coded buffs applied to the entities?  e.g. "displace towards X" and thus could be interpolated?


- Server tick rate is speed of causality.
- Client has a speculative view of the universe that also ticks at same speed.
- Can "observe" client view.
- Rendering can also ask individual entities to interpolate into the future?


## Next MVP
* Client interpolation
** Entities show interploted positions on client.


* Have separate client and server update rates.
* Clients react at 60fpts to queued inputs only?
* Clients will queue commands for server
* Commands are only sent on server ticks?
* Client can ask individual entities to predict with a delta forward from last tick?


## ECS
* Entity component system would have entities just have an id and a shape.
* Shapes would then hold components.


## Dealing with Time
* Server is always behind client.
* Client and server both run same simulation with numbered ticks.
* If client ever recieves tick ahead of current, updates to that tick as present.
* if client recieves tick behind current, resimulates from that tick.