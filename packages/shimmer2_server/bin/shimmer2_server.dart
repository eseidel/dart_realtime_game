import 'dart:async';
import 'dart:convert';
import 'package:socket_io/socket_io.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'package:shimmer2_shared/shimmer2_shared.dart';

class GameMap {
  final ISize size = ISize(100, 100);

  IPoint randomPosition() {
    var random = Random();
    return IPoint(random.nextInt(size.width), random.nextInt(size.height));
  }
}

abstract class Entity {
  final String id;
  IPoint position;
  ISize size;

  Entity({required this.id, required this.position, required this.size});

  NetEntity toNetEntity() => NetEntity(
        id: id,
        position: position,
        size: size,
      );

  // Convenience
  Map<String, dynamic> toJson() => toNetEntity().toJson();

  void tick();
}

class PlayerEntity extends Entity {
  PlayerEntity({
    required super.id,
    required super.position,
    required super.size,
  });

  @override
  void tick() {}
}

class PathFollower extends Entity {
  List<IPoint> waypoints;
  int currentWaypointIndex = 0;

  PathFollower({
    required super.id,
    required super.position,
    required super.size,
    required this.waypoints,
  });

  @override
  void tick() {
    currentWaypointIndex = (currentWaypointIndex + 1) % waypoints.length;
    position = waypoints[currentWaypointIndex];
  }
}

class Game {
  GameMap map = GameMap();
  List<Entity> entities = [];
  Game();

  void initialize() {
    var size = map.size;
    entities.add(PathFollower(
      id: 'circle',
      position: IPoint(10, 10),
      size: ISize(10, 10),
      waypoints: [
        IPoint(size.xPercent(.5), size.yPercent(.25)),
        IPoint(size.xPercent(.75), size.yPercent(.5)),
        IPoint(size.xPercent(.5), size.yPercent(.75)),
        IPoint(size.xPercent(.25), size.yPercent(.5)),
      ],
    ));
  }

  void tick() {
    for (var entity in entities) {
      entity.tick();
    }
  }
}

class ShimmerServer {
  final int port;
  // FIXME: Not sure this map is needed, could just store the extra data
  // on the ServerEntities?
  Map<String, String> activeClients = {};
  Game game = Game();

  ShimmerServer({this.port = 3000});

  Entity? playerEntityForClient(String socketId) {
    var entityId = activeClients[socketId];
    if (entityId != null) {
      return game.entities.firstWhere((element) => element.id == entityId);
    }
    return null;
  }

  PlayerEntity createPlayer(String socketId) {
    var entityId = Uuid().v1();
    var entity = PlayerEntity(
      id: entityId,
      position: game.map.randomPosition(),
      size: ISize(10, 10),
    );
    game.entities.add(entity);
    activeClients[socketId] = entityId;
    return entity;
  }

  void connectClient(String socketId) {
    print("connectClient: $socketId");
    var existingEntity = playerEntityForClient(socketId);
    assert(existingEntity == null);
    createPlayer(socketId);
  }

  void disconnectClient(String socketId) {
    print("disconnectClient: $socketId");
    var entityId = activeClients.remove(socketId);
    game.entities.removeWhere((element) => element.id == entityId);
  }

  void start() {
    var io = Server();
    io.on('connection', (client) {
      // FIXME: Use some an explicit connect message instead.
      connectClient(client.id);
      print('connection default namespace');
      client.on('msg', (data) {
        print('data from default => $data');
        client.emit('fromServer', "ok");
      });

      client.on('move_player_to', (data) {
        var position = IPoint.fromJson(jsonDecode(data));
        print('move_player_to ${client.id} $position');
      });

      client.on('disconnect', (_) {
        disconnectClient(client.id);
      });
    });
    io.listen(port);

    game.initialize();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      game.tick();
      for (var client in io.sockets.sockets) {
        client.emit(
            "tick",
            jsonEncode(NetClientUpdate(
              playerEntityId: playerEntityForClient(client.id)!.id,
              entities:
                  game.entities.map((entity) => entity.toNetEntity()).toList(),
            ).toJson()));
      }
    });
  }
}

void main() {
  var server = ShimmerServer(port: 3000);
  server.start();
}
