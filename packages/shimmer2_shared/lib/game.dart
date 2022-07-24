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

  void tick() {
    // if on client, only for client_id = me.
    mover.tick();
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

  void tick() {
    Vector2 delta = (destination - delegate.position).toVector2();
    delegate.angle = delta.angleTo(upVector);

    // This makes it stop when it gets there.
    if (delta.length > delegate.speed) {
      delta.normalize();
      delta *= delegate.speed;
      delegate.action = Action.moving;
    } else {
      delegate.action = Action.idle;
    }
    delegate.position += ISize.fromVector2(delta);
  }
}

// Immutable GameState
class GameState {
  final List<Entity> entities;

  const GameState.empty() : entities = const [];

  GameState.fromNet(NetGameState net)
      : entities = net.entities.map((e) => Entity.fromNet(e)).toList();
}

// Mutable Game
// Game and GameState could be combined?
class Game {
  GameMap map = GameMap();
  List<Entity> entities = [];
  Game();

  NetGameState toNet() => NetGameState(
        entities: entities.map((entity) => entity.toNet()).toList(),
      );

  void tick() {
    for (var entity in entities) {
      entity.tick();
    }
  }
}
