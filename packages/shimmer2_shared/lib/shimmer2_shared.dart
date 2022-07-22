import 'package:vector_math/vector_math.dart';

class IPoint {
  final int x;
  final int y;
  const IPoint(this.x, this.y);

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };

  IPoint.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'];

  operator -(IPoint other) => ISize(x - other.x, y - other.y);
  operator +(ISize other) => IPoint(x + other.width, y + other.height);

  Vector2 toVector2() => Vector2(x.toDouble(), y.toDouble());

  @override
  String toString() => 'IPoint($x, $y)';
}

class ISize {
  final int width;
  final int height;
  const ISize(this.width, this.height);

  ISize.fromVector2(Vector2 vector)
      : width = vector.x.toInt(),
        height = vector.y.toInt();

  int xPercent(double percent) => (width * percent).floor();
  int yPercent(double percent) => (height * percent).floor();

  Vector2 toVector2() => Vector2(width.toDouble(), height.toDouble());

  @override
  String toString() => 'ISize($width, $height)';
}

class NetEntity {
  final String id;
  IPoint position;
  ISize size;
  NetEntity({required this.id, required this.position, required this.size});

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.x,
        'y': position.y,
        'width': size.width,
        'height': size.height,
      };

  NetEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        size = ISize(json['width'], json['height']),
        position = IPoint(json['x'], json['y']);
}

class NetClientUpdate {
  final String playerEntityId;
  final List<NetEntity> entities;

  const NetClientUpdate({required this.playerEntityId, required this.entities});

  Map<String, dynamic> toJson() => {
        'playerEntityId': playerEntityId,
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  NetClientUpdate.fromJson(Map<String, dynamic> json)
      : playerEntityId = json['playerEntityId'],
        entities = json['entities']
            .map<NetEntity>((json) => NetEntity.fromJson(json))
            .toList();
}

abstract class Movable {
  IPoint get position;
  set position(IPoint newPosition);

  double get speed;
}

// Some sort of movement class which given a destination point will move towards it.
class MoveTowards<T extends Movable> {
  final T delegate;
  IPoint destination;
  bool done = false;

  MoveTowards(this.delegate) : destination = delegate.position;

  set desintation(IPoint newDestination) {
    destination = newDestination;
    done = false;
  }

  void tick() {
    Vector2 delta = (destination - delegate.position).toVector2();
    // This makes it stop when it gets there.
    if (delta.length > delegate.speed) {
      delta.normalize();
      delta *= delegate.speed;
    } else {
      done = true;
    }
    delegate.position += ISize.fromVector2(delta);
  }
}
