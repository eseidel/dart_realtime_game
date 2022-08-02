import 'package:server/server.dart';

void main() {
  var server = ShimmerServer(port: 3000);
  server.start();
}
