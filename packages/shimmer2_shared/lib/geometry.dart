import 'package:vector_math/vector_math_64.dart';
export 'package:vector_math/vector_math_64.dart';

// class IPoint {
//   final int x;
//   final int y;
//   const IPoint(this.x, this.y);

//   Map<String, dynamic> toJson() => {
//         'x': x,
//         'y': y,
//       };

//   IPoint.fromJson(Map<String, dynamic> json)
//       : x = json['x'],
//         y = json['y'];

//   operator -(IPoint other) => ISize(x - other.x, y - other.y);
//   operator +(ISize other) => IPoint(x + other.width, y + other.height);

//   IPoint.fromVector2(Vector2 vector)
//       : x = vector.x.toInt(),
//         y = vector.y.toInt();

//   Vector2 toVector2() => Vector2(x.toDouble(), y.toDouble());

//   @override
//   String toString() => 'IPoint($x, $y)';
// }

// class ISize {
//   final int width;
//   final int height;
//   const ISize(this.width, this.height);

//   ISize.fromVector2(Vector2 vector)
//       : width = vector.x.toInt(),
//         height = vector.y.toInt();

//   int xPercent(double percent) => (width * percent).floor();
//   int yPercent(double percent) => (height * percent).floor();

//   Vector2 toVector2() => Vector2(width.toDouble(), height.toDouble());

//   @override
//   String toString() => 'ISize($width, $height)';
// }

final Vector2 upVector = Vector2(0, 1);
