import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:shimmer2_shared/shimmer2_shared.dart';

void debugRegister(io.Socket socket) {
  const List events = [
    'connect',
    'connect_error',
    'connect_timeout',
    'connecting',
    'disconnect',
    'error',
    'reconnect',
    'reconnect_attempt',
    'reconnect_failed',
    'reconnect_error',
    'reconnecting',
    'ping',
    'pong'
  ];
  for (var event in events) {
    socket.on(event, (data) {
      print(event);
      print(data);
    });
  }
}

class ServerConnection {
  io.Socket socket;

  ServerConnection(Uri uri)
      :
        // OptionBuilder stuff shouldn't be needed, but seems to be
        // for dart:io.
        socket = io.io(uri.toString(),
            io.OptionBuilder().setTransports(['websocket']).build()) {
    socket.on('connect', (_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    debugRegister(socket);
    socket.on('event', (data) => print(data));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  }

  // Could just use the players username instead?
  void onSetPlayerEntityId(void Function(String playerEntityId) callback) {
    socket.on('connected', (data) {
      callback(data['entity_id']);
    });
  }

  void onUpdateFromServer(void Function(NetGameState update) callback) {
    socket.on('tick', (data) {
      var entities = NetGameState.fromJson(jsonDecode(data));
      callback(entities);
    });
  }

  void dispose() {
    socket.dispose();
  }
}
