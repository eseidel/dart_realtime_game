import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class TapIndicator extends PositionComponent {
  static final _paint = Paint()..color = const Color.fromARGB(255, 0, 200, 145);

  TapIndicator({super.position});

  @override
  void onMount() {
    super.onMount();
    add(CircleComponent(radius: 3, paint: _paint, anchor: Anchor.center));
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.2)),
        RemoveEffect(),
      ]),
    );
  }
}

abstract class ServerControlledComponent extends PositionComponent {
  ServerControlledComponent(
      {super.size, super.anchor, super.position, super.angle});
}

class DummyRenderer extends ServerControlledComponent {
  static final _outerPaint = Paint()
    ..color = const Color.fromARGB(255, 200, 184, 40);
  static final _innerPaint = Paint()
    ..color = const Color.fromARGB(255, 200, 40, 168);

  DummyRenderer({super.position, required super.size, super.angle})
      : super(anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    var outer =
        TriangleComponent(size: size, paint: _outerPaint, position: size / 2);
    var inner = TriangleComponent(
        size: size / 2, position: Vector2.zero(), paint: _innerPaint);
    outer.add(inner);
    add(outer);
    return super.onLoad();
  }
}

class TriangleComponent extends PolygonComponent {
  TriangleComponent({
    required Vector2 size,
    required Vector2 position,
    required Paint paint,
  }) : super.relative(
          [Vector2(0, 1), Vector2(-1, -1), Vector2(1, -1)],
          parentSize: size,
          position: position,
          anchor: Anchor.center,
          paint: paint,
        );
}

class PlayerRenderer extends ServerControlledComponent {
  static final _outerPaint = Paint()
    ..color = const Color.fromARGB(255, 40, 200, 40);
  static final _innerPaint = Paint()
    ..color = const Color.fromARGB(255, 200, 40, 168);

  PlayerRenderer({required double size, super.position})
      : super(size: Vector2(size, size), anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    var outer =
        TriangleComponent(size: size, paint: _outerPaint, position: size / 2);
    var inner = TriangleComponent(
      size: size / 2,
      position: Vector2.zero(),
      paint: _innerPaint,
    );
    outer.add(inner);
    add(outer);
    return super.onLoad();
  }
}

class PlayerComponent extends ServerControlledComponent {
  PlayerComponent({super.position, required super.size, super.angle})
      : super(anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    add(PlayerRenderer(size: width, position: size / 2)); // Renderer
    return super.onLoad();
  }
}

abstract class PlayerActions {
  void movePlayerTo(Vector2 position);
}

class ShimmerRenderer extends FlameGame with TapDetector {
  final PlayerActions actions;
  late PlayerComponent playerComponent;
  final Vector2 gameSize;

  ShimmerRenderer({required this.actions, required this.gameSize});

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    camera.viewport = FixedResolutionViewport(gameSize);
  }

  @override
  void onTapUp(TapUpInfo info) {
    var gamePosition = info.eventPosition.game;
    add(TapIndicator(position: gamePosition));
    actions.movePlayerTo(gamePosition);
    super.onTapUp(info); // Should this call super?
  }
}
