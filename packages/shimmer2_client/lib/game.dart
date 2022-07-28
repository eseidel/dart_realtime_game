import 'package:flutter/widgets.dart' as widgets;

import 'package:shimmer2_shared/shimmer2_shared.dart';

import 'network.dart';
import 'render_canvas.dart';

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

class GameController extends widgets.StatefulWidget {
  const GameController({widgets.Key? key}) : super(key: key);

  @override
  widgets.State<GameController> createState() => _GameControllerState();
}

class _GameControllerState extends widgets.State<GameController> {
  ClientState? _clientState;
  late ServerConnection _connection;

  void _connectToServer() {
    var url = 'http://localhost:3000';
    // var url = "http://shimmer-c3juc.ondigitalocean.app:3000/";
    _connection = ServerConnection(Uri.parse(url));
    _connection.onJoinGame((joinResponse) {
      setState(() {
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
      });
      _connection.onServerUpdate((update) {
        _clientState?.updateFromServer(update);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  @override
  void dispose() {
    _connection.dispose();
    super.dispose();
  }

  @override
  widgets.Widget build(widgets.BuildContext context) {
    if (_clientState == null) {
      return const widgets.Center(
        child: widgets.Text('Connecting to server...'),
      );
    }
    return GameView(
      clientState: _clientState!,
      onAction: (action) {
        if (action is MoveHeroAction) {
          _connection.socket.emit('move_player_to',
              {'x': action.destination.x, 'y': action.destination.y});
        }
      },
    );
  }
}

class GameView extends widgets.StatelessWidget {
  final ClientState clientState;
  final widgets.ValueChanged<Action> onAction;

  const GameView({
    super.key,
    required this.clientState,
    required this.onAction,
  });

  @override
  widgets.Widget build(widgets.BuildContext context) {
    return ShimmerRenderer(
      clientState: clientState,
    );
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
