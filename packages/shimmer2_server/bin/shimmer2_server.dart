import 'dart:async';
import 'dart:convert';
import 'package:socket_io/socket_io.dart';

class IPoint {
  final int x;
  final int y;
  const IPoint(this.x, this.y);
}

class ISize {
  final int width;
  final int height;
  const ISize(this.width, this.height);

  int xPercent(double percent) => (width * percent).floor();
  int yPercent(double percent) => (height * percent).floor();
}

abstract class Entity {
  final String id;
  IPoint position;
  Entity({required this.id, required this.position});

  void tick();

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.x,
        'y': position.y,
      };
}

class GameMap {
  final ISize size = ISize(100, 100);
}

class PathFollower extends Entity {
  List<IPoint> waypoints;
  int currentWaypointIndex = 0;

  PathFollower({
    required super.id,
    required super.position,
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

  void start() {
    var size = map.size;
    entities.add(PathFollower(
      id: 'circle',
      position: IPoint(10, 10),
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

void main() {
  var io = Server();
  io.on('connection', (client) {
    print('connection default namespace');
    client.on('msg', (data) {
      print('data from default => $data');
      client.emit('fromServer', "ok");
    });
  });
  io.listen(3000);

  var game = Game();
  game.start();

  Timer.periodic(const Duration(seconds: 2), (timer) {
    game.tick();
    io.sockets.emit("tick", jsonEncode(game.entities));
  });
}
