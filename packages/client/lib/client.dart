import 'dart:html' show CanvasElement, document;
import 'package:client/render.dart';

import 'package:client/game.dart';
import 'package:client/playcanvas_render.dart';

class Client {
  void main() {
    var game = GameController();
    game.connectToServer();
    var renderRoot = ShimmerRenderRoot();

    // Init PlayCanvas

    var canvas = document.getElementById('canvas') as CanvasElement;

    var playCanvas =
        PlayCanvasAdapter(onAction: ((action) => game.onAction(action)));
    List<Renderer> prepareFrame(Duration deltaTime) {
      var world = game.world;
      if (world == null) {
        return [];
      }
      // Run the pipeline
      renderRoot.prepareFrame(world, deltaTime);
      return renderRoot.renderSystem.renderers;
    }

    playCanvas.init(canvas);
    playCanvas.start(prepareFrame);
  }
}
