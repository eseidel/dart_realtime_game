import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:shimmer2_client/game.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

class TapIndicator extends PositionComponent {
  static final _paint = Paint()..color = const Color.fromARGB(255, 0, 200, 145);

  TapIndicator({super.position});

  @override
  void onMount() {
    super.onMount();
    add(CircleComponent(
      radius: 3,
      paint: _paint,
      anchor: Anchor.center,
    ));
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
  static final _paint = Paint()
    ..color = const Color.fromARGB(255, 200, 40, 168);

  DummyRenderer({super.position, required super.size, super.angle})
      : super(anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    add(TriangleComponent(
      size: size,
      paint: _paint,
      position: size / 2,
    ));
    return super.onLoad();
  }
}

class TriangleComponent extends PolygonComponent {
  TriangleComponent({
    required Vector2 size,
    required Vector2 position,
    required Paint paint,
  }) : super(
          [
            Vector2(0, 1),
            Vector2(-1, -1),
            Vector2(1, -1),
          ],
          size: size,
          position: position,
          anchor: Anchor.center,
          paint: paint,
        );
}

class PlayerRenderer extends ServerControlledComponent {
  static final _paint = Paint()..color = const Color.fromARGB(255, 40, 200, 40);

  PlayerRenderer({required double size, super.position})
      : super(size: Vector2(size, size), anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    add(TriangleComponent(
      size: size,
      paint: _paint,
      position: size / 2,
    ));
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
  void movePlayerTo(IPoint position);
}

class ShimmerRenderer extends FlameGame with TapDetector {
  final UnitSystem unitSystem;
  final PlayerActions actions;
  late PlayerComponent playerComponent;

  ShimmerRenderer({required this.actions, required this.unitSystem});

  @override
  Future<void> onLoad() async {
    camera.viewport =
        FixedResolutionViewport(Vector2.all(unitSystem.renderSize.x));
  }

  @override
  void onTapUp(TapUpInfo info) {
    var gamePosition = info.eventPosition.game;
    add(TapIndicator(position: gamePosition));
    var serverPosition = unitSystem.fromRenderPointToGame(gamePosition);
    actions.movePlayerTo(serverPosition);
    super.onTapUp(info); // Should this call super?
  }
}
