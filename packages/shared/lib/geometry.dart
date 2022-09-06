import 'package:vector_math/vector_math_64.dart';
export 'package:vector_math/vector_math_64.dart';
import 'package:json_annotation/json_annotation.dart';

class JsonVector2Position extends JsonConverter<Vector2, Map<String, dynamic>> {
  const JsonVector2Position();

  @override
  Vector2 fromJson(Map<String, dynamic> json) {
    return Vector2(json['x'], json['y']);
  }

  @override
  Map<String, dynamic> toJson(Vector2 object) {
    return {'x': object.x, 'y': object.y};
  }
}

class JsonVector2Size extends JsonConverter<Vector2, Map<String, dynamic>> {
  const JsonVector2Size();

  @override
  Vector2 fromJson(Map<String, dynamic> json) {
    return Vector2(json['width'], json['height']);
  }

  @override
  Map<String, dynamic> toJson(Vector2 object) {
    return {'width': object.x, 'height': object.y};
  }
}

final Vector2 upVector = Vector2(0, 1);
