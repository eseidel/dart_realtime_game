import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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

class ClientEntity {
  final String id;
  final int x;
  final int y;
  ClientEntity({required this.id, required this.x, required this.y});

  ClientEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        x = json['x'],
        y = json['y'];
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

  void onTick(void Function(List<ClientEntity> entities) callback) {
    socket.on('tick', (data) {
      var entities = jsonDecode(data)
          .map<ClientEntity>((json) => ClientEntity.fromJson(json))
          .toList();
      callback(entities);
    });
  }
}

void main() {
  runApp(const MyGame());
}

class MyGame extends StatefulWidget {
  const MyGame({Key? key}) : super(key: key);

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  late ServerConnection connection;
  List<ClientEntity> entities = [];

  @override
  void initState() {
    connection = ServerConnection(Uri.parse('http://localhost:3000'));
    connection.onTick((entities) {
      setState(() {
        this.entities = entities;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Stack(fit: StackFit.expand, children: [
      CustomPaint(
        painter: WorldPainter(entities),
      ),
    ]));
  }
}

class WorldPainter extends CustomPainter {
  final List<ClientEntity> entities;

  WorldPainter(this.entities) : super();

  void paintEntity(Canvas canvas, ClientEntity entity) {
    var paint = Paint()..color = Colors.green;
    var offset = Offset(entity.x.toDouble(), entity.y.toDouble());
    canvas.drawCircle(offset, 5.0, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var entity in entities) {
      paintEntity(canvas, entity);
    }
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true;
  }
}
