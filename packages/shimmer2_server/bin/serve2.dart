import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() {
  var handler = webSocketHandler((webSocket) {
    print("WebSocket connection opened");
    webSocket.stream.listen((message) {
      print(message);
      webSocket.sink.add("echo $message");
    });
  });

  shelf_io.serve(handler, InternetAddress.anyIPv4, 3000).then((server) {
    print('Serving ipv4 at ws://${server.address.host}:${server.port}');
  });
  // shelf_io.serve(handler, InternetAddress.anyIPv6, 3000).then((server) {
  //   print('Serving ipv6 at ws://${server.address.host}:${server.port}');
  // });
}
