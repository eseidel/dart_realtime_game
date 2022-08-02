// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'components.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhysicsComponent _$PhysicsComponentFromJson(Map<String, dynamic> json) =>
    PhysicsComponent(
      position: const JsonVector2Position()
          .fromJson(json['position'] as Map<String, dynamic>),
      size: const JsonVector2Size()
          .fromJson(json['size'] as Map<String, dynamic>),
      angle: (json['angle'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
    );

Map<String, dynamic> _$PhysicsComponentToJson(PhysicsComponent instance) =>
    <String, dynamic>{
      'position': const JsonVector2Position().toJson(instance.position),
      'size': const JsonVector2Size().toJson(instance.size),
      'angle': instance.angle,
      'speed': instance.speed,
    };

DestinationComponent _$DestinationComponentFromJson(
        Map<String, dynamic> json) =>
    DestinationComponent(
      location: const JsonVector2Position()
          .fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DestinationComponentToJson(
        DestinationComponent instance) =>
    <String, dynamic>{
      'location': const JsonVector2Position().toJson(instance.location),
    };

ViewportComponent _$ViewportComponentFromJson(Map<String, dynamic> json) =>
    ViewportComponent(
      visualCenter: const JsonVector2Position()
          .fromJson(json['visualCenter'] as Map<String, dynamic>),
      visualRadius: (json['visualRadius'] as num).toDouble(),
    );

Map<String, dynamic> _$ViewportComponentToJson(ViewportComponent instance) =>
    <String, dynamic>{
      'visualCenter': const JsonVector2Position().toJson(instance.visualCenter),
      'visualRadius': instance.visualRadius,
    };

MapComponent _$MapComponentFromJson(Map<String, dynamic> json) => MapComponent(
      size: const JsonVector2Size()
          .fromJson(json['size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MapComponentToJson(MapComponent instance) =>
    <String, dynamic>{
      'size': const JsonVector2Size().toJson(instance.size),
    };
