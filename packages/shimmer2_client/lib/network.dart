import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logging/logging.dart';

import 'package:shimmer2_shared/shimmer2_shared.dart';

final log = Logger('Shimmer2Client');

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
      log.fine(event);
      log.fine(data);
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
    log.info("connecting to $uri");
    socket.on('connect', (_) {
      log.info('connected to $uri');
    });
    debugRegister(socket);
    socket.on('disconnect', (_) {
      log.info('disconnected from $uri');
    });
  }

  void onJoinGame(void Function(NetJoinResponse join) callback) {
    socket.on('connected', (data) {
      callback(NetJoinResponse.fromJson(data));
    });
  }

  void onServerUpdate(void Function(ServerUpdate update) callback) {
    socket.on('tick', (data) {
      callback(ServerUpdate.fromJson(jsonDecode(data)));
    });
  }

  void dispose() {
    socket.dispose();
  }
}
