import 'dart:convert';

import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter/scheduler.dart';
import 'package:flame/game.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

import 'network.dart';
import 'render.dart';

typedef ServerPosition = IPoint;

class UnitSystem {
  final ISize gameSize;
  final Vector2 renderSize;

  final double gameToRender;
  final double renderToGame;

  UnitSystem({required this.gameSize, required this.renderSize})
      : gameToRender = renderSize.x / gameSize.width,
        renderToGame = gameSize.width / renderSize.x;
  // Could assert that height scale matches.

  double scale(int value, double scale) => value * scale;
  int scaleAndFloor(double value, double scale) => (value * scale).floor();

  double toRender(int value) => scale(value, renderToGame);
  int toGame(double value) => scaleAndFloor(value, gameToRender);

  ServerPosition fromRenderPointToGame(Vector2 game) {
    return ServerPosition(toGame(game.x), toGame(game.y));
  }

  Vector2 fromGamePointToRender(IPoint game) {
    return Vector2(toRender(game.x), toRender(game.y));
  }

  Vector2 fromGameSizeToRender(ISize game) {
    return Vector2(toRender(game.width), toRender(game.height));
  }
}

class RenderTree extends widgets.StatefulWidget {
  final PlayerActions actions;
  final String? playerEntityId; // entity we're controlling

  const RenderTree({
    super.key,
    required this.actions,
    this.playerEntityId,
  });

  @override
  widgets.State<RenderTree> createState() => _RenderTreeState();
}

// Like Flutter's Element tree, this maps from the GameState
// to the renderer (the FlameGame object).
class _RenderTreeState extends widgets.State<RenderTree> {
  late ShimmerRenderer renderer;
  final UnitSystem unitSystem = UnitSystem(
    gameSize: const ISize(100, 100),
    renderSize: Vector2(200, 200),
  );
  Map<String, ServerControlledComponent> entityMap = {};

  ServerControlledComponent _createRendererInner(Entity entity) {
    // FIXME: This is the wrong way to do this, we should create renderers
    // based on entity type, not just which one we're controlling.
    if (entity.id == widget.playerEntityId) {
      return PlayerComponent(
        size: unitSystem.fromGameSizeToRender(entity.size),
        position: unitSystem.fromGamePointToRender(entity.position),
        angle: entity.angle,
      );
    }
    return DummyRenderer(
      size: unitSystem.fromGameSizeToRender(entity.size),
      position: unitSystem.fromGamePointToRender(entity.position),
      angle: entity.angle,
    );
  }

  ServerControlledComponent createRendererFor(Entity entity) {
    print("createRendererFor ${entity.id}");
    var component = _createRendererInner(entity);
    renderer.add(component);
    entityMap[entity.id] = component;
    return component;
  }

  void updateRenderer(Entity entity, ServerControlledComponent component) {
    component.size = unitSystem.fromGameSizeToRender(entity.size);
    component.position = unitSystem.fromGamePointToRender(entity.position);
    component.angle = entity.angle;
  }

  void removeRendererFor(String id) {
    var component = entityMap.remove(id);
    component?.removeFromParent();
  }

  void updateToGameState(GameState state) {
    setState(() {
      var unseenIds = Set.from(entityMap.keys);
      for (var entity in state.entities) {
        var renderer = entityMap[entity.id];
        if (renderer == null) {
          createRendererFor(entity);
        } else {
          updateRenderer(entity, renderer);
        }
        unseenIds.remove(entity.id);
      }
      for (var id in unseenIds) {
        removeRendererFor(id);
      }
    });
  }

  @override
  void initState() {
    renderer = ShimmerRenderer(actions: widget.actions, unitSystem: unitSystem);
    super.initState();
  }

  @override
  widgets.Widget build(widgets.BuildContext context) {
    return GameWidget(game: renderer);
  }
}

class ShimmerMain extends widgets.StatefulWidget {
  const ShimmerMain({widgets.Key? key}) : super(key: key);

  @override
  widgets.State<ShimmerMain> createState() => _ShimmerMainState();
}

// Main class of the game.  Starts the network connection, keeps hold of the
// local client state and the renderer and keeps them in sync.
class _ShimmerMainState extends widgets.State<ShimmerMain>
    with widgets.SingleTickerProviderStateMixin<ShimmerMain>
    implements PlayerActions {
  late ServerConnection _connection;
  late ClientGameModel gameModel = ClientGameModel();
  String? playerEntityId;
  widgets.GlobalKey<_RenderTreeState> _renderTreeKey = widgets.GlobalKey();
  late Ticker _idleTicker;

  @override
  void initState() {
    _idleTicker = createTicker((elapsed) {
      _renderTreeKey.currentState?.updateToGameState(gameModel.projectedState);
    })
      ..start();
    _connection = ServerConnection(Uri.parse('http://localhost:3000'));
    _connection.onUpdateFromServer((update) {
      gameModel.processUpdateFromServer(update);
    });
    _connection.onSetPlayerEntityId((playerEntityId) {
      setState(() {
        this.playerEntityId = playerEntityId;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _idleTicker.dispose();
    _connection.dispose();
    super.dispose();
  }

  @override
  void movePlayerTo(IPoint position) {
    // TODO: Should this clamp to the map size?
    _connection.socket.emit('move_player_to', jsonEncode(position));
  }

  @override
  widgets.Widget build(widgets.BuildContext context) {
    return RenderTree(
      key: _renderTreeKey,
      actions: this,
      playerEntityId: playerEntityId,
    );
  }
}

class ClientGameModel {
  GameState _lastStateFromServer = GameState(
    entities: [],
    tickNumber: 0,
    clientTime: DateTime.now(),
  );

  GameState _lastProjection = GameState(
    entities: [],
    tickNumber: 0,
    clientTime: DateTime.now(),
  );

  void processUpdateFromServer(NetGameState state) {
    _lastStateFromServer = GameState.fromNet(state);
    _lastProjection = _lastStateFromServer;
    // apply local inputs to projected state?
  }

  GameState get projectedState {
    // Figure out how far ahead of lastStateFromServer we are.
    var deltaFromLastTick =
        DateTime.now().difference(_lastProjection.clientTime!);
    _lastProjection = _lastProjection.playedForward(deltaFromLastTick);
    // Apply any local inputs.
    return _lastProjection;
  }
}
