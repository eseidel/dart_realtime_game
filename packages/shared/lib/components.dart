import 'package:json_annotation/json_annotation.dart';

import 'geometry.dart';
import 'ecs.dart';

part 'components.g.dart';

typedef ComponentDeserializer = Component Function(Map<String, dynamic>);

const Map<String, ComponentDeserializer> kComponentDeserializers = {
  'ViewportComponent': ViewportComponent.fromJson,
  'MapComponent': MapComponent.fromJson,
  'PhysicsComponent': PhysicsComponent.fromJson,
  'DestinationComponent': DestinationComponent.fromJson,
};

const Map<String, Type> kComponentTypes = {
  'ViewportComponent': ViewportComponent,
  'MapComponent': MapComponent,
  'PhysicsComponent': PhysicsComponent,
  'DestinationComponent': DestinationComponent,
};

@JsonSerializable()
class PhysicsComponent extends Component {
  @JsonVector2Position()
  final Vector2 position;
  @JsonVector2Size()
  final Vector2 size;
  final double angle;
  final double speed;

  PhysicsComponent({
    required this.position,
    required this.size,
    required this.angle,
    required this.speed,
  });

  PhysicsComponent copyWith({
    Vector2? position,
    Vector2? size,
    double? angle,
    double? speed,
  }) {
    return PhysicsComponent(
      position: position ?? this.position,
      size: size ?? this.size,
      angle: angle ?? this.angle,
      speed: speed ?? this.speed,
    );
  }

  factory PhysicsComponent.fromJson(Map<String, dynamic> json) =>
      _$PhysicsComponentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PhysicsComponentToJson(this);
}

// @JsonSerializable()
// class SkillshotComponent extends Component {
//   // Angle is in PhysicsComponent
//   // Speed is in PhysicsComponent
//   // Percentage complete? Or max distance or max time?
//   // stops on collision? (with which things?)
//   // Damage component?

//   final double maxTime;
//   final double timeRemaining;
//   final double damage;

//   SkillshotComponent({
//     required this.maxTime,
//     required this.timeRemaining,
//     required this.damage,
//   });

//   factory SkillshotComponent.fromJson(Map<String, dynamic> json) =>
//       _$SkillshotComponentFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$SkillshotComponentToJson(this);
// }

@JsonSerializable()
class DestinationComponent extends Component {
  @JsonVector2Position()
  final Vector2 location;

  DestinationComponent({
    required this.location,
  });

  factory DestinationComponent.fromJson(Map<String, dynamic> json) =>
      _$DestinationComponentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DestinationComponentToJson(this);
}

@JsonSerializable()
class ViewportComponent extends Component {
  @JsonVector2Position()
  final Vector2 visualCenter;
  final double visualRadius;

  ViewportComponent({required this.visualCenter, required this.visualRadius});

  // Rect mapRect(Size canvasSize) {
  //   final size = canvasSize / zoomLevel;
  //   return Rect.fromLTWH(
  //     position.x - size.width / 2,
  //     position.y - size.height / 2,
  //     size.width,
  //     size.height,
  //   );
  // }

  @override
  String toString() => 'ViewportComponent($visualCenter, $visualRadius)';

  factory ViewportComponent.fromJson(Map<String, dynamic> json) =>
      _$ViewportComponentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ViewportComponentToJson(this);
}

@JsonSerializable()
class MapComponent extends Component {
  @JsonVector2Size()
  final Vector2 size;

  MapComponent({required this.size});

  factory MapComponent.fromJson(Map<String, dynamic> json) =>
      _$MapComponentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MapComponentToJson(this);
}
