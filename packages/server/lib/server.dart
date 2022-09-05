import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PlayerState {
  Entity hero;
  Entity player;

  PlayerState(this.hero, this.player);
}

typedef SocketId = int;

typedef ConnectionCallback = void Function(Map<String, dynamic> data);

class Connection {
  final SocketId id;
  final WebSocketChannel channel;
  Map<String, List<ConnectionCallback>> handlers = {};

  Connection({required this.id, required this.channel}) {
    channel.stream.listen((message) {
      _dispatchMessage(Message.fromJson(json.decode(message)));
    });
  }

  void on(String type, ConnectionCallback callback) {
    handlers[type] ??= [];
    handlers[type]!.add(callback);
  }

  void _dispatchMessage(Message message) {
    var callbacks = handlers[message.type];
    if (callbacks == null || callbacks.isEmpty) {
      print("No handler for ${message.type}");
      return;
    }
    for (var callback in callbacks) {
      callback(message.data);
    }
  }

  void send(String type, Map<String, dynamic> data) {
    channel.sink.add(Message(type, data).toJson());
  }
}

typedef OnConnection = void Function(Connection connection);

class ConnectionHandler {
  List<Connection> connections = [];
  int nextSocketId = 0;
  OnConnection? onConnection;

  void listen(int port) {
    var handler = webSocketHandler((WebSocketChannel webSocket) {
      print("WebSocket connection opened");
      var connection = Connection(id: nextSocketId++, channel: webSocket);
      connections.add(connection);
      onConnection?.call(connection);
      webSocket.sink.done.then((_) {
        print("WebSocket connection closed");
        connection._dispatchMessage(Message("disconnect", {}));
        connections.remove(connection);
      });
    });

    shelf_io.serve(handler, InternetAddress.anyIPv4, 3000).then((server) {
      print('Serving ipv4 at ws://${server.address.host}:${server.port}');
    });
  }
}

class ShimmerServer {
  final int port;
  // FIXME: Not sure this map is needed, could just store the extra data
  // on the ServerEntities?
  final Map<SocketId, PlayerState> activeClients = {};
  final Game game;

  ShimmerServer({this.port = 3000, int ticksPerSecond = 10})
      : game = Game(ticksPerSecond: ticksPerSecond);

  // Used to tell the client which entity is them so they can follow it with camera.
  PlayerState? playerStateForClient(SocketId socketId) =>
      activeClients[socketId];

  PlayerState createPlayer(SocketId socketId) {
    var hero = game.world.createEntity(ExecutionLocation.server);
    hero.setComponent(
      PhysicsComponent(
        position: game.randomPosition(),
        size: Vector2(10, 10),
        angle: 0.0,
        speed: 20,
      ),
    );

    var player = game.world.createEntity(ExecutionLocation.server);
    var playerState = PlayerState(hero, player);
    activeClients[socketId] = playerState;
    return playerState;
  }

  PlayerState connectClient(SocketId socketId) {
    assert(playerStateForClient(socketId) == null);
    return createPlayer(socketId);
  }

  void disconnectClient(SocketId socketId) {
    // FIXME: Need a way to reliably clean up all state from clients?
    // Currently seem to leak at least 2 PhysicsComponents per connection.
    final playerState = activeClients.remove(socketId)!;
    game.world
      ..destroyEntity(playerState.player)
      ..destroyEntity(playerState.hero);
  }

  void start() {
    var handler = ConnectionHandler();
    handler.onConnection = (Connection client) {
      // FIXME: Use some an explicit connect/login message instead.
      var playerState = connectClient(client.id);
      client.send(
        'connected',
        NetJoinResponse(
          game.match.id,
          playerState.player.id,
          playerState.hero.id,
        ).toJson(),
      );

      // FIXME: Generalize to an action queue.
      client.on('move_player_to', (Map<String, dynamic> data) {
        var position = Vector2(data['x'].toDouble(), data['y'].toDouble());
        playerStateForClient(client.id)
            ?.hero
            .setComponent(DestinationComponent(location: position));
      });

      client.on('disconnect', (_) {
        disconnectClient(client.id);
      });
    };
    handler.listen(port);

    Timer.periodic(game.tickDuration, (timer) {
      game.tick();
      for (var client in handler.connections) {
        client.send("tick", game.toNet().toJson());
      }
    });
  }
}
