import 'geometry.dart';
import 'game.dart';

class NetEntity {
  final String id;
  IPoint position;
  ISize size;
  double angle;
  double speed;
  Action action;

  NetEntity({
    required this.id,
    required this.position,
    required this.size,
    required this.angle,
    required this.action,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.x,
        'y': position.y,
        'width': size.width,
        'height': size.height,
        'angle': angle,
        'action': action.name,
        'speed': speed,
      };

  NetEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        size = ISize(json['width'], json['height']),
        position = IPoint(json['x'], json['y']),
        angle = json['angle'],
        speed = json['speed'],
        action = Action.values.byName(json['action']);
}

class NetGameState {
  final List<NetEntity> entities;

  const NetGameState({required this.entities});

  Map<String, dynamic> toJson() => {
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  NetGameState.fromJson(Map<String, dynamic> json)
      : entities = json['entities']
            .map<NetEntity>((json) => NetEntity.fromJson(json))
            .toList();
}
