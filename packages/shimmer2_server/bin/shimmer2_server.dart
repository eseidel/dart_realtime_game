import 'dart:async';
import 'dart:convert';
import 'package:socket_io/socket_io.dart';
import 'package:uuid/uuid.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

class ShimmerServer {
  final int port;
  final int msPerTick;
  // FIXME: Not sure this map is needed, could just store the extra data
  // on the ServerEntities?
  Map<String, String> activeClients = {};
  Game game = Game();

  ShimmerServer({this.port = 3000, int ticksPerSecond = 10})
      : msPerTick = 1000 ~/ ticksPerSecond;

  Entity? playerEntityForClient(String socketId) {
    var entityId = activeClients[socketId];
    if (entityId != null) {
      return game.entities.firstWhere((element) => element.id == entityId);
    }
    return null;
  }

  Entity createPlayer(String socketId) {
    var entityId = Uuid().v1();
    var entity = Entity(
      id: entityId,
      position: game.map.randomPosition(),
      size: ISize(10, 10),
      angle: 0.0,
      speed: 300.0,
      action: Action.idle,
    );
    game.entities.add(entity);
    activeClients[socketId] = entityId;
    return entity;
  }

  String connectClient(String socketId) {
    var existingEntity = playerEntityForClient(socketId);
    assert(existingEntity == null);
    return createPlayer(socketId).id;
  }

  void disconnectClient(String socketId) {
    var entityId = activeClients.remove(socketId);
    game.entities.removeWhere((element) => element.id == entityId);
  }

  void start() {
    var io = Server();
    io.on('connection', (client) {
      // FIXME: Use some an explicit connect message instead.
      var entityId = connectClient(client.id);
      client.emit('connected', {
        'entity_id': entityId,
      });

      client.on('move_player_to', (data) {
        var position = IPoint.fromJson(jsonDecode(data));
        playerEntityForClient(client.id)?.moveTo(position);
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

void main() {
  var server = ShimmerServer(port: 3000);
  server.start();
}
