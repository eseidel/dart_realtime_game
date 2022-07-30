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

  shelf_io.serve(handler, 'localhost', 3000).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}
