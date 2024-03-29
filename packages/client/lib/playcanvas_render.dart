import 'dart:html' show CanvasElement, document;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:playcanvas/playcanvas.dart' as pc;

import 'package:shared/shared.dart';
import 'package:client/render.dart';

typedef OnAction = void Function(ClientAction action);

class PlayCanvasAdapter {
  final groundHeight = 0.5;
  final Map<EntityId, pc.Entity> _pcEntities = {};
  late pc.Application app;

  pc.Ray ray = pc.Ray();
  pc.Vec3 hitPosition = pc.Vec3(0, 0, 0);
  late pc.Entity cameraEntity;
  late pc.BoundingBox groundBox;

  pc.Entity get root => app.root;

  OnAction onAction;

  PlayCanvasAdapter({required this.onAction});

  void onMouseDown(pc.MouseEvent event) {
    if (event.button == pc.MOUSEBUTTON_LEFT) {
      doRayCast(event);
    }
  }

  void onTouchStart(event) {
    if (event.touches.length == 1) {
      doRayCast(event.touches[0]);
      event.event.preventDefault();
    }
  }

  void doRayCast(screenPosition) {
    // Initialise the ray and work out the direction of the ray from
    // the a screen position

    cameraEntity.camera.screenToWorld(screenPosition.x, screenPosition.y,
        cameraEntity.camera.nearClip, ray.origin);
    cameraEntity.camera.screenToWorld(screenPosition.x, screenPosition.y,
        cameraEntity.camera.farClip, ray.direction);
    ray.direction.sub(ray.origin).normalize();

    // Test the ray against the ground
    var result = groundBox.intersectsRay(ray, hitPosition);
    if (result) {
      var destination = Vector2(hitPosition.x, hitPosition.z);
      onAction(MoveHeroAction(destination: destination));
    }
  }

  void init(CanvasElement canvas) {
    app = pc.Application(
        canvas,
        jsify({
          'mouse': pc.Mouse(document.body!),
          'touch': pc.TouchDevice(document.body!),
          'elementInput': pc.ElementInput(canvas),
        }));

    app.mouse.on(pc.EVENT_MOUSEDOWN, pc.singleArgCallback(onMouseDown));
    app.touch.on(pc.EVENT_TOUCHSTART, pc.singleArgCallback(onTouchStart));

    // Create an Entity with a camera component
    cameraEntity = pc.Entity();
    cameraEntity.addComponent(
      "camera",
      pc.CameraOptions(
        clearColor: pc.Color(30 / 255, 30 / 255, 30 / 255),
      ),
    );

    cameraEntity.rotateLocal(-30, 0, 0);
    cameraEntity.translate(gameSize.x / 2, 50, 1.2 * gameSize.y);
    root.addChild(cameraEntity);

    // Create an Entity for the ground
    final material = pc.StandardMaterial();
    material.diffuse = pc.Color(0.3, 0.5, 0.2);
    material.update();

    var ground = pc.Entity();

    ground.setLocalScale(gameSize.x, 1, gameSize.y);
    ground.setLocalPosition(0, -0.5, 0);
    // Make bottom-left corner of the ground the origin.
    ground.translate(gameSize.x / 2, 0, gameSize.y / 2);
    groundBox = pc.BoundingBox(
      pc.Vec3(gameSize.x / 2, 0, gameSize.y / 2),
      pc.Vec3(gameSize.x / 2, 0, gameSize.y / 2),
    );
    ground.addComponent(
        "render", pc.RenderOptions(type: "box", material: material));

    root.addChild(ground);

    // Create an entity with a light component
    final light = pc.Entity();
    light.addComponent(
        "light",
        pc.LightOptions(
          type: "directional",
          color: pc.Color(1, 1, 1),
          castShadows: true,
          intensity: 1,
          shadowBias: 0.2,
          shadowDistance: 16,
          normalOffsetBias: 0.05,
          shadowResolution: 2048,
        ));

    light.setLocalEulerAngles(45, 30, 0);
    root.addChild(light);

    // Create a 2D screen
    final screen = pc.Entity();
    screen.setLocalScale(0.01, 0.01, 0.01);
    screen.addComponent(
        "screen",
        pc.ScreenOptions(
          referenceResolution: pc.Vec2(1280, 720),
          screenSpace: true,
        ));

    root.addChild(screen);
  }

  void start(List<Renderer> Function(Duration deltaTime) prepareFrame) {
    app.on("update",
        allowInterop(([dt, _, __, ___, ____, _____, ______, _______]) {
      var renderers = prepareFrame(Duration(milliseconds: (1000 * dt).toInt()));
      updatePlayCanvas(renderers);
    }));
    app.start();
  }

  void updateEntityFromRenderer(pc.Entity entity, Renderer renderer) {
    assert(_pcEntities[renderer.id] == entity);
    entity.setPosition(renderer.position.x, groundHeight, renderer.position.y);
    entity.setLocalEulerAngles(0, renderer.angle, 0);
    entity.setLocalScale(renderer.radius, 1, renderer.radius);
  }

  pc.Entity createEntityFromRenderer(Renderer renderer) {
    final entity = pc.Entity();
    entity.setLocalScale(0.5, 0.5, 0.5);
    entity.addComponent(
        "render",
        pc.RenderOptions(
          type: "capsule",
        ));

    entity.setLocalPosition(
        renderer.position.x, groundHeight, renderer.position.y);
    entity.setLocalEulerAngles(0, renderer.angle, 0);
    entity.setLocalScale(renderer.radius, 1, renderer.radius);
    _pcEntities[renderer.id] = entity;
    print("added entity at ${renderer.position.x}, ${renderer.position.y}");
    return entity;
  }

  void updatePlayCanvas(List<Renderer> renderers) {
    // Go through each renderer, make sure we have a playcanvas object
    // if we don't, create one.  If we do, update, or remove.

    var unseenIds = Set<EntityId>.from(_pcEntities.keys);
    for (var renderer in renderers) {
      unseenIds.remove(renderer.id);
      var existing = _pcEntities[renderer.id];
      if (existing != null) {
        updateEntityFromRenderer(existing, renderer);
      } else {
        var entity = createEntityFromRenderer(renderer);
        root.addChild(entity);
      }
    }
    for (var id in unseenIds) {
      var pcEntity = _pcEntities.remove(id);
      pcEntity!.destroy();
    }
  }
}
