import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

import 'game.dart';

class RenderSystem extends System {
  final List<Renderer> renderers = [];

  @override
  void update(World world, double dt) {
    renderers.clear();
    for (final entity in world.query<PhysicsComponent>()) {
      final physics = entity.getComponent<PhysicsComponent>();
      renderers.add(RenderTriangle(
        offset: Offset(physics.position.x, physics.position.y),
        radius: physics.size.x / 2,
        angle: physics.angle,
      ));
    }
  }
}

abstract class Renderer {
  void paint(Canvas canvas, Duration elapsed);
}

class RenderTriangle extends Renderer {
  final Offset offset;
  final double radius;
  final double angle;
  final Path _path;
  final Paint _paint;

  RenderTriangle({
    required this.offset,
    required this.radius,
    required this.angle,
  })  : _path = Path()
          ..moveTo(0, 0)
          ..lineTo(radius, 0)
          ..lineTo(radius / 2, radius)
          ..close(),
        _paint = Paint()
          ..color = const Color.fromARGB(255, 255, 0, 0)
          ..style = PaintingStyle.fill;

  // The translate and rotation could be done by some parent class?
  @override
  void paint(Canvas canvas, Duration elapsed) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    canvas.drawPath(_path, _paint); // The only line unique to this class.
    canvas.restore();
  }
}

class ShimmerPainter extends CustomPainter {
  final ViewportComponent viewport;
  final List<Renderer> renderers;

  ShimmerPainter(this.viewport, this.renderers);

  void paintDebugBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 123, 124, 113);
    var p = viewport.position;
    var s = viewport.size;
    var rect = Rect.fromLTWH(p.x, p.y, s.x, s.y);
    canvas.drawRect(rect, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // FIXME: don't warp the canvas, rather just provide a pannable camera.
    canvas
      ..save()
      ..translate(viewport.position.x, viewport.position.y)
      ..scale(size.width / viewport.size.x, size.height / viewport.size.y);
    paintDebugBackground(canvas, size);
    for (final renderer in renderers) {
      renderer.paint(canvas, Duration.zero);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShimmerPainter oldDelegate) {
    return true;
    // FIXME: shouldRepaint is wrong.
    // Needs to at least check viewport?
    // return renderers != oldDelegate.renderers;
  }
}

class ShimmerRenderer extends StatefulWidget {
  final ClientState clientState;
  final ValueChanged<ClientAction> onAction;
  const ShimmerRenderer(
      {super.key, required this.clientState, required this.onAction});

  @override
  State<ShimmerRenderer> createState() => _ShimmerRendererState();
}

class _ShimmerRendererState extends State<ShimmerRenderer>
    with SingleTickerProviderStateMixin<ShimmerRenderer> {
  late Ticker _idleTicker;
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
  void prepareFrame(Duration elapsed) {
    setState(() {
      // Run the projection system.
      // _renderTreeKey.currentState?.updateToGameState(gameModel.projectedState);
      // query for entities
      // construct renderers
      final dt = updateTimeDelta(elapsed);
      renderSystem.update(widget.clientState.world, dt);
    });
  }

  @override
  void initState() {
    _idleTicker = createTicker(prepareFrame)..start();
    super.initState();
  }

  @override
  void dispose() {
    _idleTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dummyViewport =
        ViewportComponent(position: Vector2.zero(), size: Vector2(1000, 1000));
    // TODO: Store the viewport somewhere, perhaps the ECS?
    // widget.clientState.player.getComponent<ViewportComponent>(),
    return GestureDetector(
      child: CustomPaint(
        painter: ShimmerPainter(dummyViewport, renderSystem.renderers),
      ),
      onTapUp: (TapUpDetails details) {
        // FIXME: Correct for viewport.
        var destination =
            Vector2(details.localPosition.dx, details.localPosition.dy);
        widget.onAction(MoveHeroAction(destination: destination));
      },
    );
  }
}
