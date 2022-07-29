import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

import 'game.dart';
import 'dart:math';

class RenderSystem extends System {
  final List<Renderer> renderers = [];

  @override
  void update(World world, double dt) {
    renderers.clear();
    for (final entity in world.query<MapComponent>()) {
      final map = entity.getComponent<MapComponent>();
      renderers.add(RenderDebugMap(map: map));
    }

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

class RenderDebugMap extends Renderer {
  final MapComponent map;

  RenderDebugMap({required this.map});

  static final _paint = Paint()
    ..color = const Color.fromARGB(255, 123, 124, 113);

  @override
  void paint(Canvas canvas, Duration elapsed) {
    final rect = Rect.fromLTWH(0, 0, map.size.x, map.size.y);
    canvas.drawRect(rect, _paint);
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
    var gameSize = Vector2(200, 200);
    var middle = gameSize / 2;
    var radius = min(middle.x, middle.y);
    final dummyViewport =
        ViewportComponent(visualCenter: middle, visualRadius: radius);
    // TODO: Store the viewport somewhere, perhaps the ECS?
    // widget.clientState.player.getComponent<ViewportComponent>(),
    return ShimmerViewport(
        viewport: dummyViewport,
        child: GestureDetector(
          onTapUp: (TapUpDetails details) {
            var destination =
                Vector2(details.localPosition.dx, details.localPosition.dy);
            widget.onAction(MoveHeroAction(destination: destination));
          },
          child: ShimmerPainter(renderers: renderSystem.renderers),
        ));
  }
}

class ShimmerPainter extends SingleChildRenderObjectWidget {
  final List<Renderer> renderers;

  const ShimmerPainter({
    super.key,
    required this.renderers,
    super.child,
  });

  @override
  RenderShimmerPainter createRenderObject(BuildContext context) {
    return RenderShimmerPainter(renderers: renderers);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderShimmerPainter renderObject) {
    renderObject.renderers = renderers;
  }
}

class RenderShimmerPainter extends RenderProxyBox {
  RenderShimmerPainter({
    required List<Renderer> renderers,
    RenderBox? child,
  })  : _renderers = renderers,
        super(child);

  List<Renderer> _renderers;
  List<Renderer> get renderers => _renderers;
  set renderers(List<Renderer> value) {
    if (value != _renderers) {
      _renderers = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) =>
      constraints.constrain(Size.zero);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    for (final renderer in _renderers) {
      renderer.paint(canvas, Duration.zero);
    }
  }
}

class ShimmerViewport extends SingleChildRenderObjectWidget {
  final ViewportComponent viewport;

  const ShimmerViewport({
    super.key,
    required this.viewport,
    super.child,
  });

  @override
  RenderShimmerViewport createRenderObject(BuildContext context) {
    return RenderShimmerViewport(viewport: viewport);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderShimmerViewport renderObject) {
    renderObject.viewport = viewport;
  }
}

class RenderShimmerViewport extends RenderProxyBox {
  RenderShimmerViewport({
    required ViewportComponent viewport,
    RenderBox? child,
  })  : _viewport = viewport,
        super(child);

  ViewportComponent _viewport;
  ViewportComponent get viewport => _viewport;
  set viewport(ViewportComponent value) {
    if (value != _viewport) {
      _viewport = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _paintTranform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) =>
      constraints.constrain(Size.zero);

  Matrix4 _paintTranform = Matrix4.identity();

  void _updatePaintTransform() {
    final canvasRadius = size.shortestSide / 2;
    final scale = canvasRadius / _viewport.visualRadius;
    _paintTranform = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale, scale)
      ..translate(-_viewport.visualCenter.x, -_viewport.visualCenter.y);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _updatePaintTransform();
    final canvas = context.canvas;
    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..transform(_paintTranform.storage);
    child?.paint(context, Offset.zero);
    canvas.restore();
  }
}
