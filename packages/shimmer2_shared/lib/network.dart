import 'geometry.dart';
import 'game.dart';

class NetEntity {
  final String id;
  Vector2 position;
  Vector2 size;
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
        'width': size.x,
        'height': size.y,
        'angle': angle,
        'action': action.name,
        'speed': speed,
      };

  NetEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        size = Vector2(json['width'], json['height']),
        position = Vector2(json['x'], json['y']),
        angle = json['angle'],
        speed = json['speed'],
        action = Action.values.byName(json['action']);
}

class NetGameState {
  final int tickNumber;
  final DateTime serverTime;
  final DateTime? clientTime;
  final List<NetEntity> entities;

  const NetGameState({
    required this.tickNumber,
    required this.entities,
    required this.serverTime,
    this.clientTime,
  });

  Map<String, dynamic> toJson() => {
        'tickNumber': tickNumber,
        'serverTime': serverTime.millisecondsSinceEpoch,
        'clientTime': clientTime?.millisecondsSinceEpoch,
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  NetGameState.fromJson(Map<String, dynamic> json)
      : entities = json['entities']
            .map<NetEntity>((json) => NetEntity.fromJson(json))
            .toList(),
        tickNumber = json['tickNumber'],
        serverTime = DateTime.fromMillisecondsSinceEpoch(json['serverTime']),
        clientTime = json['clientTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['clientTime'])
            : null;
}
