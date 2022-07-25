import 'geometry.dart';
import 'network.dart';
import 'dart:math';

class GameMap {
  final ISize size = ISize(100, 100);

  IPoint randomPosition() {
    var random = Random();
    return IPoint(random.nextInt(size.width), random.nextInt(size.height));
  }
}

enum Action {
  idle,
  moving,
}

class Entity implements Movable {
  final String id;
  @override
  IPoint position;
  ISize size;
  double angle;
  @override
  double speed;
  Action action;
  late MoveTowards mover;

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
        action = net.action {
    mover = MoveTowards(this);
  }

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

  void moveTo(IPoint position) {
    mover.destination = position;
  }

  void update(double delta) {
    // if on client, only for client_id = me.
    mover.update(delta);
  }
}

abstract class Movable {
  IPoint get position;
  set position(IPoint newPosition);
  set angle(double angle);
  set action(Action action);

  double get speed;
}

// Some sort of movement class which given a destination point will move towards it.
class MoveTowards<T extends Movable> {
  final T delegate;
  IPoint destination;

  MoveTowards(this.delegate) : destination = delegate.position;

  set desintation(IPoint newDestination) {
    destination = newDestination;
  }

  void update(double timeDelta) {
    Vector2 delta = (destination - delegate.position).toVector2();
    delegate.angle = delta.angleTo(upVector);

    double speed = delegate.speed * timeDelta;
    // This makes it stop when it gets there.
    if (delta.length > speed) {
      delta.normalize();
      delta *= speed;
      delegate.action = Action.moving;
    } else {
      delegate.action = Action.idle;
    }
    delegate.position += ISize.fromVector2(delta);
  }
}

// Immutable GameState
class GameState {
  final int tickNumber;
  final DateTime? serverTime;
  final DateTime? clientTime;

  final List<Entity> entities;

  GameState({
    required this.tickNumber,
    required this.entities,
    this.serverTime,
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
        serverTime = net.serverTime,
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

  static const serverTicksPerSecond = 10;

  Game({int ticksPerSecond = serverTicksPerSecond})
      : tickDuration = Duration(milliseconds: 1000 ~/ ticksPerSecond);

  double secondsPerTick() => tickDuration.inMilliseconds / 1000;

  NetGameState toNet() => NetGameState(
        tickNumber: tickNumber,
        serverTime: DateTime.now(),
        entities: entities.map((entity) => entity.toNet()).toList(),
      );

  void tick() {
    tickNumber++;
    for (var entity in entities) {
      entity.update(secondsPerTick());
    }
  }
}
