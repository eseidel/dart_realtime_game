import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:shared/shared.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  var socket = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

  int pointIndex = 0;
  var points = [
    Vector2(.5, .25)..multiply(gameSize),
    Vector2(.75, .5)..multiply(gameSize),
    Vector2(.5, .75)..multiply(gameSize),
    Vector2(.25, .5)..multiply(gameSize),
  ];

  var timer = Timer.periodic(const Duration(seconds: 2), (timer) {
    pointIndex = (pointIndex + 1) % points.length;
    var point = points[pointIndex];
    socket.sink.add(Message('move_player_to', {
      'x': point.x,
      'y': point.y,
    }).toJson());
  });

  socket.sink.done.then((_) {
    timer.cancel();
  });
}
