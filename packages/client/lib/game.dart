import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:convert';

class ClientState {
  final World world;

  // Singleton entity, which holds things like viewport.
  final Entity match;
  final Entity player;
  final Entity hero;

  ClientState({
    required this.world,
    required this.match,
    required this.player,
    required this.hero,
  });

  void updateFromServer(ServerUpdate update) {
    world.applySnapshot(update.worldSnapshot);
    // re-apply the uncommitted inputs
    // project forward as needed.
    // do we allow inputs on top of projections?
  }
}

class GameController {
  ClientState? _clientState;
  late WebSocketChannel _connection;

  bool isProduction() {
    return const bool.fromEnvironment('dart.vm.product');
  }

  World? get world => _clientState?.world;

  void connectToServer() {
    // FIXME: This is a hack, should come from an environment variable?
    var url = 'ws://localhost:3000';
    if (isProduction()) {
      // Production uses a route proxy instead of a custom port.
      url = 'wss://${Uri.base.host}/api';
      // e.g. 'wss://shimmer-c3juc.ondigitalocean.app/api'
    }
    var uri = Uri.parse(url);
    print("Connecting to $uri");
    _connection = WebSocketChannel.connect(uri);
    _connection.stream.listen((encodedMessage) {
      var message = Message.fromJson(json.decode(encodedMessage));
      if (message.type == "connected") {
        var joinResponse = NetJoinResponse.fromJson(message.data);
        var world = World.empty();
        final clientState = ClientState(
          world: world,
          match: world.getEntity(joinResponse.matchId),
          hero: world.getEntity(joinResponse.heroId),
          player: world.getEntity(joinResponse.playerId),
        );
        // TODO: Client can't write to the world. Need to send an action to the
        // server.
        // clientState.player.setComponent(ViewportComponent(
        //   position: clientState.hero.getComponent<PhysicsComponent>().position,
        //   size: clientState.match.getComponent<MapComponent>().size,
        // ));
        _clientState = clientState;
      } else if (message.type == "tick") {
        _clientState!.updateFromServer(ServerUpdate.fromJson(message.data));
      } else {
        print("Unhandled message type: ${message.type}");
      }
    });
  }

  void onAction(ClientAction action) {
    if (action is MoveHeroAction) {
      print("MoveHeroAction: ${action.destination}");
      _connection.sink.add(Message('move_player_to',
          {'x': action.destination.x, 'y': action.destination.y}).toJson());
    }
  }
}

// This needs to run physics forward n-ticks when we are behind at least
// one tick from the server.
// class ClientGameModel {
//   GameState _lastStateFromServer = GameState(
//     entities: [],
//     tickNumber: 0,
//     clientTime: DateTime.now(),
//   );

//   GameState _lastProjection = GameState(
//     entities: [],
//     tickNumber: 0,
//     clientTime: DateTime.now(),
//   );

//   void processUpdateFromServer(ServerUpdate state) {
//     _lastStateFromServer = GameState.fromNet(state);
//     _lastProjection = _lastStateFromServer;
//     // apply local inputs to projected state?
//   }

//   // FIXME: This is wrong, it should only project forward whole ticks.
//   GameState get projectedState {
//     // Figure out how far ahead of lastStateFromServer we are.
//     var deltaFromLastTick =
//         DateTime.now().difference(_lastProjection.clientTime!);
//     // Avoid ticks too small to get lost in integer math.
//     if (deltaFromLastTick.inMilliseconds > 30) {
//       _lastProjection = _lastProjection.playedForward(deltaFromLastTick);
//     }
//     // Apply any local inputs.
//     return _lastProjection;
//   }
// }
