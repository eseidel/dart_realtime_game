import 'dart:html' show CanvasElement, document;
// ignore: library_prefixes
import 'dart:math' as Math;

import 'package:js/js_util.dart';
import 'package:playcanvas/math.dart' as math;
import 'package:playcanvas/playcanvas.dart' as pc;

// import 'game.dart';

void main() {
  // var game = GameController();

  // Init PlayCanvas

  var canvas = document.getElementById('canvas') as CanvasElement;
  final app = pc.Application(
      canvas,
      jsify({
        'mouse': pc.Mouse(document.body!),
        'touch': pc.TouchDevice(document.body!),
        'elementInput': pc.ElementInput(canvas),
      }));

  app.start();

  // Create an Entity with a camera component
  final camera = pc.Entity();
  camera.addComponent(
    "camera",
    pc.CameraOptions(
      clearColor: pc.Color(30 / 255, 30 / 255, 30 / 255),
    ),
  );

  camera.rotateLocal(-30, 0, 0);
  camera.translateLocal(0, 0, 7);
  app.root.addChild(camera);

  // Create an Entity for the ground
  final material = pc.StandardMaterial();
  material.diffuse = pc.Color.RED;
  material.update();

  final ground = pc.Entity();
  ground.addComponent(
      "render", pc.RenderOptions(type: "box", material: material));

  ground.setLocalScale(50, 1, 50);
  ground.setLocalPosition(0, -0.5, 0);
  app.root.addChild(ground);

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
  app.root.addChild(light);

  // Create a 2D screen
  final screen = pc.Entity();
  screen.setLocalScale(0.01, 0.01, 0.01);
  screen.addComponent(
      "screen",
      pc.ScreenOptions(
        referenceResolution: pc.Vec2(1280, 720),
        screenSpace: true,
      ));

  app.root.addChild(screen);

  ///
  /// Converts a coordinate in world space into a screen's space.
  ///
  /// @param {pc.Vec3} worldPosition - the Vec3 representing the world-space coordinate.
  /// @param {pc.CameraComponent} camera - the Camera.
  /// @param {pc.ScreenComponent} screen - the Screen
  /// @returns {pc.Vec3} a Vec3 of the input worldPosition relative to the camera and screen. The Z coordinate represents the depth,
  /// and negative numbers signal that the worldPosition is behind the camera.
  ///
  // pc.Vec3 worldToScreenSpace(worldPosition, camera, screen) {
  //   final screenPos = camera.worldToScreen(worldPosition);

  //   // take pixel ratio into account
  //   final pixelRatio = app.graphicsDevice.maxPixelRatio;
  //   screenPos.x *= pixelRatio;
  //   screenPos.y *= pixelRatio;

  //   // account for screen scaling
  //   final scale = screen.scale;

  //   // invert the y position
  //   screenPos.y = screen.resolution.y - screenPos.y;

  //   // put that into a Vec3
  //   return pc.Vec3(
  //       screenPos.x / scale, screenPos.y / scale, screenPos.z / scale);
  // }

  void createPlayer(id, startingAngle, speed, radius) {
    // Create a capsule entity to represent a player in the 3d world
    final entity = pc.Entity();
    entity.setLocalScale(0.5, 0.5, 0.5);
    entity.addComponent(
        "render",
        pc.RenderOptions(
          type: "capsule",
        ));

    app.root.addChild(entity);

    final angle = startingAngle;
    final height = 0.5;
    entity.setLocalPosition(radius * Math.sin(angle * math.DEG_TO_RAD), height,
        radius * Math.cos(angle * math.DEG_TO_RAD));
    entity.setLocalEulerAngles(0, angle + 90, 0);
  }

  createPlayer(1, 135, 30, 1.5);
  createPlayer(2, 65, -18, 1);
  createPlayer(3, 0, 15, 2.5);
}
