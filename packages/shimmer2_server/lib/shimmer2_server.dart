import 'dart:async';
import 'dart:convert';
import 'package:socket_io/socket_io.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

class PlayerState {
  Entity hero;
  Entity player;

  PlayerState(this.hero, this.player);
}

class ShimmerServer {
  final int port;
  // FIXME: Not sure this map is needed, could just store the extra data
  // on the ServerEntities?
  final Map<String, PlayerState> activeClients = {};
  final Game game;

  ShimmerServer({this.port = 3000, int ticksPerSecond = 1})
      : game = Game(ticksPerSecond: ticksPerSecond);

  // Used to tell the client which entity is them so they can follow it with camera.
  PlayerState? playerStateForClient(String socketId) => activeClients[socketId];

  PlayerState createPlayer(String socketId) {
    var hero = game.world.createEntity(ExecutionLocation.server);
    hero.setComponent(
      PhysicsComponent(
        position: game.randomPosition(),
        size: Vector2(10, 10),
        angle: 0.0,
        speed: 20,
      ),
    );

    var player = game.world.createEntity(ExecutionLocation.server);
    var playerState = PlayerState(hero, player);
    activeClients[socketId] = playerState;
    return playerState;
  }

  PlayerState connectClient(String socketId) {
    assert(playerStateForClient(socketId) == null);
    return createPlayer(socketId);
  }

  void disconnectClient(String socketId) {
    final playerState = activeClients.remove(socketId)!;
    game.world
      ..destroyEntity(playerState.player)
      ..destroyEntity(playerState.hero);
  }

  void start() {
    var io = Server();
    io.on('connection', (client) {
      // FIXME: Use some an explicit connect/login message instead.
      var playerState = connectClient(client.id);
      client.emit(
        'connected',
        NetJoinResponse(
          game.match.id,
          playerState.player.id,
          playerState.hero.id,
        ),
      );

      // FIXME: Generalize to an action queue.
      client.on('move_player_to', (data) {
        var position = Vector2(data['x'], data['y']);
        playerStateForClient(client.id)
            ?.hero
            .setComponent(DestinationComponent(location: position));
      });

      client.on('disconnect', (_) {
        disconnectClient(client.id);
      });
    });
    io.listen(port);

    Timer.periodic(game.tickDuration, (timer) {
      game.tick();
      for (var client in io.sockets.sockets) {
        client.emit("tick", jsonEncode(game.toNet().toJson()));
      }
    });
  }
}
