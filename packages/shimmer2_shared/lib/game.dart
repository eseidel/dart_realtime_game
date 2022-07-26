import 'geometry.dart';
import 'network.dart';
import 'dart:math';

class GameMap {
  final Vector2 size = Vector2(1000, 1000);

  Vector2 randomPosition() {
    var random = Random();
    return Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y);
  }
}

enum Action {
  idle,
  moving,
}

class Entity implements Movable {
  final String id;
  @override
  Vector2 position;
  Vector2 size;
  double angle; // radians
  @override
  double speed;
  Action action;
  late MoveTowards? mover;

  Entity({
    required this.id,
    required this.position,
    required this.size,
    required this.angle,
    required this.action,
    required this.speed,
  }) {
    mover = MoveTowards(this);
  }

  Entity.fromNet(NetEntity net)
      : id = net.id,
        position = net.position,
        size = net.size,
        angle = net.angle,
        speed = net.speed,
        action = net.action,
        mover = null;

  NetEntity toNet() => NetEntity(
        id: id,
        position: position,
        size: size,
        angle: angle,
        speed: speed,
        action: action,
      );

  // Convenience
  Map<String, dynamic> toJson() => toNet().toJson();

  void moveTo(Vector2 position) {
    mover?.destination = position;
  }

  // Vector2 unitVector() {
  //   return Vector2(-cos(angle), sin(angle));
  // }

  void update(double delta) {
    // if on client, only for client_id = me.
    if (mover != null) {
      mover!.update(delta);
    } else {
      // dead reconing.
      if (action == Action.moving) {
        var heading = Vector2(-cos(angle), -sin(angle));
        // print(heading);
        heading.scale(speed * delta);
        position += heading;
        // print("scaled: $heading position: $position");
      }
    }
  }
}

abstract class Movable {
  Vector2 get position;
  set position(Vector2 newPosition);
  set angle(double angleRadians);
  set action(Action action);

  double get speed;
}

// Some sort of movement class which given a destination point will move towards it.
class MoveTowards<T extends Movable> {
  final T delegate;
  Vector2 destination;

  MoveTowards(this.delegate) : destination = delegate.position;

  set desintation(Vector2 newDestination) {
    destination = newDestination;
  }

  void update(double timeDelta) {
    Vector2 delta = destination - delegate.position;

    double speed = delegate.speed * timeDelta;
    // This makes it stop when it gets there.
    if (delta.length > speed) {
      delegate.angle = upVector.angleToSigned(delta);
      delta.normalize();
      delta *= speed;
      delegate.action = Action.moving;
    } else {
      delegate.action = Action.idle;
    }
    delegate.position += delta;
  }
}

// Immutable GameState
class GameState {
  final int tickNumber;
  final DateTime? clientTime;

  final List<Entity> entities;

  GameState({
    required this.tickNumber,
    required this.entities,
    this.clientTime,
  });

  GameState playedForward(Duration delta) {
    var newEntities = List<Entity>.from(entities);
    // If delta is more than tick time, we need to play multiple ticks.
    for (var entity in newEntities) {
      entity.update(delta.inMilliseconds / 1000);
    }
    return GameState(
      // Should this have a tick number?
      tickNumber: tickNumber + 1,
      entities: newEntities,
      clientTime: DateTime.now(),
    );
  }

  GameState.fromNet(NetGameState net)
      : tickNumber = net.tickNumber,
        clientTime = DateTime.now(),
        entities = net.entities.map((e) => Entity.fromNet(e)).toList();
}

// Mutable Game
// Game and GameState could be combined?
class Game {
  GameMap map = GameMap();
  List<Entity> entities = [];
  int tickNumber = 0;
  Duration tickDuration;

  Game({required int ticksPerSecond})
      : tickDuration = Duration(milliseconds: 1000 ~/ ticksPerSecond);

  double secondsPerTick() => tickDuration.inMilliseconds / 1000;

  NetGameState toNet() => NetGameState(
        tickNumber: tickNumber,
        entities: entities.map((entity) => entity.toNet()).toList(),
      );

  void tick() {
    tickNumber++;
    for (var entity in entities) {
      entity.update(secondsPerTick());
    }
  }
}
