import 'dart:convert';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shimmer2_shared/shimmer2_shared.dart';

void main() {
  io.Socket socket = io.io('http://localhost:3000',
      io.OptionBuilder().setTransports(['websocket']).build());

  socket.on('connect', (_) {
    int pointIndex = 0;
    final ISize size = ISize(100, 100);
    var points = [
      IPoint(size.xPercent(.5), size.yPercent(.25)),
      IPoint(size.xPercent(.75), size.yPercent(.5)),
      IPoint(size.xPercent(.5), size.yPercent(.75)),
      IPoint(size.xPercent(.25), size.yPercent(.5)),
    ];

    var timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      pointIndex = (pointIndex + 1) % points.length;
      var point = points[pointIndex];
      socket.emit('move_player_to', jsonEncode(point));
    });

    socket.on('disconnect', (_) {
      timer.cancel();
    });
  });
}
