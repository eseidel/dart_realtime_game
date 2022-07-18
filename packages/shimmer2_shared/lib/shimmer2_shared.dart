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

  @override
  String toString() => 'IPoint($x, $y)';
}

class ISize {
  final int width;
  final int height;
  const ISize(this.width, this.height);

  int xPercent(double percent) => (width * percent).floor();
  int yPercent(double percent) => (height * percent).floor();

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
