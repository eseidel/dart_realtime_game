import 'geometry.dart';

class Action {}

class MoveHeroAction extends Action {
  final Vector2 destination;

  MoveHeroAction({required this.destination});
}
