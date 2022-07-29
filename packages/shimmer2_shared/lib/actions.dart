import 'geometry.dart';

class ClientAction {}

class MoveHeroAction extends ClientAction {
  final Vector2 destination;

  MoveHeroAction({required this.destination});
}
