import 'dart:convert';
import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shimmer2_shared/shimmer2_shared.dart';

void main() {
  io.Socket socket = io.io('http://localhost:3000',
      io.OptionBuilder().setTransports(['websocket']).build());

  socket.on('connect', (_) {
    int pointIndex = 0;
    Vector2 size = Vector2(200, 200);
    var points = [
      Vector2(.5, .25)..multiply(size),
      Vector2(.75, .5)..multiply(size),
      Vector2(.5, .75)..multiply(size),
      Vector2(.25, .5)..multiply(size),
    ];

    var timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      pointIndex = (pointIndex + 1) % points.length;
      var point = points[pointIndex];
      socket.emit('move_player_to', {'x': point.x, 'y': point.y});
    });

    socket.on('disconnect', (_) {
      timer.cancel();
    });
  });
}
