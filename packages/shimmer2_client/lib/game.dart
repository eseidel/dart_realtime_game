import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/game.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

import 'network.dart';
import 'render.dart';

// class ClientEntity {
//   final String id;
//   final int x;
//   final int y;
//   ClientEntity({required this.id, required this.x, required this.y});

//   ClientEntity.fromJson(Map<String, dynamic> json)
//       : id = json['id'],
//         x = json['x'],
//         y = json['y'];
// }

class ClientMap {
  final int width;
  final int height;

  ClientMap(this.width, this.height);
}

class ClientGameState {
  final ClientMap map = ClientMap(100, 100);
  // List<ClientEntity> entities = [];
}

typedef ServerPosition = IPoint;

class UnitSystem {
  final ISize serverSize;
  final Vector2 clientSize;

  final double serverToClient;
  final double clientToServer;

  UnitSystem({required this.serverSize, required this.clientSize})
      : serverToClient = clientSize.x / serverSize.width,
        clientToServer = serverSize.width / clientSize.x;
  // Could assert that height scale matches.

  double scale(int value, double scale) => value * scale;
  int scaleAndFloor(double value, double scale) => (value / scale).floor();

  double toClient(int value) => scale(value, clientToServer);
  int toServer(double value) => scaleAndFloor(value, serverToClient);

  ServerPosition fromGamePointToServer(Vector2 game) {
    return ServerPosition(toServer(game.x), toServer(game.y));
  }

  Vector2 fromServerPointToGame(IPoint server) {
    return Vector2(toClient(server.x), toClient(server.y));
  }

  Vector2 fromServerSizeToGame(ISize server) {
    return Vector2(toClient(server.width), toClient(server.height));
  }
}

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

// Like the Element tree, this maps from the ClientGameState
// to the renderer (the FlameGame object).
class _MyGameState extends State<MyGame> implements PlayerActions {
  late ServerConnection connection;
  ClientGameState gameState = ClientGameState();
  late ShimmerGame renderer;
  final UnitSystem unitSystem = UnitSystem(
    serverSize: const ISize(100, 100),
    clientSize: Vector2(1000, 1000),
  );
  Map<String, ServerControlledComponent> entityMap = {};

  ServerControlledComponent _createRendererInner(
      NetEntity entity, bool isPlayer) {
    if (isPlayer) {
      return PlayerComponent(
        size: unitSystem.fromServerSizeToGame(entity.size),
        position: unitSystem.fromServerPointToGame(entity.position),
      );
    }
    return ServerControlledComponent(
      size: unitSystem.fromServerSizeToGame(entity.size),
      anchor: Anchor.center,
      position: unitSystem.fromServerPointToGame(entity.position),
    );
  }

  ServerControlledComponent createRendererFor(NetEntity entity, bool isPlayer) {
    print("createRendererFor ${entity.id}");
    var component = _createRendererInner(entity, isPlayer);
    renderer.add(component);
    entityMap[entity.id] = component;
    return component;
  }

  void updateRenderer(NetEntity entity, ServerControlledComponent component) {
    component.size = unitSystem.fromServerSizeToGame(entity.size);
    component.position = unitSystem.fromServerPointToGame(entity.position);
    print("${entity.position} ${entity.size}");
    print("${component.position} ${component.size}");
  }

  void removeRendererFor(String id) {
    var component = entityMap.remove(id);
    component?.removeFromParent();
  }

  void processUpdateFromServer(NetClientUpdate update) {
    setState(() {
      var unseenIds = Set.from(entityMap.keys);
      for (var entity in update.entities) {
        // Some day we may want to keep a client-side entity list
        // for speculative changes?  We would update that first and
        // then separately update the "rendering tree" from those.
        // For now we're skipping that and just updating the rendering
        // tree from the (immutable) network data directly.
        var renderer = entityMap[entity.id];
        if (renderer == null) {
          // new entity
          createRendererFor(entity, entity.id == update.playerEntityId);
        } else {
          // update
          updateRenderer(entity, renderer);
        }
        unseenIds.remove(entity.id);
      }
      // remove any unvisited entities
      for (var id in unseenIds) {
        removeRendererFor(id);
      }
    });
  }

  @override
  void initState() {
    connection = ServerConnection(Uri.parse('http://localhost:3000'));
    connection.onTick(processUpdateFromServer);
    renderer = ShimmerGame(actions: this, worldSize: unitSystem.clientSize.x);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: renderer);
  }

  @override
  void movePlayerTo(Vector2 gamePosition) {
    var serverPosition = unitSystem.fromGamePointToServer(gamePosition);
    // TODO: Should this clamp to the map size?
    // TODO: implement movePlayerTo
    connection.socket.emit('move_player_to', jsonEncode(serverPosition));
  }
}
