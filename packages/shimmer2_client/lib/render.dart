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
  ServerControlledComponent({super.size, super.anchor, super.position});
}

class DummyRenderer extends ServerControlledComponent {
  static final _paint = Paint()
    ..color = const Color.fromARGB(255, 200, 40, 168);

  DummyRenderer({super.position, required super.size})
      : super(anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    add(CircleComponent(
      radius: width / 2,
      paint: _paint,
      position: size / 2,
      anchor: Anchor.center,
    ));
    return super.onLoad();
  }
}

class PlayerRenderer extends ServerControlledComponent {
  static final _paint = Paint()..color = const Color.fromARGB(255, 40, 200, 40);

  PlayerRenderer({required double size, super.position})
      : super(size: Vector2(size, size), anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    add(RectangleComponent.square(
      size: width,
      paint: _paint,
      position: size / 2,
      anchor: Anchor.center,
    ));
    return super.onLoad();
  }
}

class PlayerComponent extends ServerControlledComponent {
  PlayerComponent({super.position, required super.size})
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

class ShimmerGame extends FlameGame with TapDetector {
  PlayerActions actions;
  late PlayerComponent playerComponent;
  final double worldSize;

  ShimmerGame({required this.actions, required this.worldSize});

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(Vector2.all(worldSize));
  }

  @override
  void onTapUp(TapUpInfo info) {
    var gamePosition = info.eventPosition.game;
    add(TapIndicator(position: gamePosition));
    actions.movePlayerTo(gamePosition);
    super.onTapUp(info); // Should this call super?
  }
}
