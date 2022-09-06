import 'package:shared/shared.dart';

class Offset {
  final double x;
  final double y;

  const Offset(this.x, this.y);
}

// Translates from Components to renders?
// Which are then later synced with the 3d version?
class RenderSystem extends System {
  final List<Renderer> renderers = [];

  @override
  void update(World world, double dt) {
    renderers.clear();
    for (final entity in world.query<PhysicsComponent>()) {
      final physics = entity.getComponent<PhysicsComponent>();
      // Update playcanvas renderers with the latest physics state.
      renderers.add(Renderer(
        id: entity.id,
        position: Offset(physics.position.x, physics.position.y),
        radius: physics.size.x / 2,
        angle: physics.angle,
      ));
    }
  }
}

// Is this just a component?
class Renderer {
  final Offset position;
  final double radius;
  final double angle;
  final EntityId id;
  Renderer({
    required this.id,
    required this.position,
    required this.radius,
    required this.angle,
  });
}

class ShimmerRenderRoot {
  Duration lastFrameTime = Duration.zero;
  RenderSystem renderSystem = RenderSystem();

  double updateTimeDelta(Duration elapsed) {
    if (lastFrameTime == Duration.zero) {
      lastFrameTime = elapsed;
      return 0.0;
    }
    double dt = (lastFrameTime - elapsed).inMilliseconds /
        Duration.millisecondsPerSecond;
    lastFrameTime = elapsed;
    return dt;
  }

  // Pipeline goes here.
  void prepareFrame(World world, Duration elapsed) {
    // Run the projection system.
    // _renderTreeKey.currentState?.updateToGameState(gameModel.projectedState);
    // query for entities
    // construct renderers
    final dt = updateTimeDelta(elapsed);
    renderSystem.update(world, dt);
  }

//   @override
//   Widget build(BuildContext context) {
//     var middle = gameSize / 2;
//     var radius = min(middle.x, middle.y);
//     final dummyViewport =
//         ViewportComponent(visualCenter: middle, visualRadius: radius);
//     // TODO: Store the viewport somewhere, perhaps the ECS?
//     // widget.clientState.player.getComponent<ViewportComponent>(),
//     return ShimmerViewport(
//         viewport: dummyViewport,
//         child: GestureDetector(
//           onTapUp: (TapUpDetails details) {
//             var local = details.localPosition;
//             var destination = Vector2(local.dx, local.dy);
//             widget.onAction(MoveHeroAction(destination: destination));
//           },
//           child: ShimmerPainter(renderers: renderSystem.renderers),
//         ));
//   }
}
