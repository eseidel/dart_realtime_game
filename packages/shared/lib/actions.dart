import 'geometry.dart';

class ClientAction {}

class MoveHeroAction extends ClientAction {
  final Vector2 destination;

  MoveHeroAction({required this.destination});
}

// Action
// Windup
// Effect
// Wind-down
// Cooldown

class UntargetedAction extends ClientAction {
  final String actionId;
  UntargetedAction({required this.actionId});
}


// No check yet if the action is available
// Always just send action to server


// SweepAttack
// Displays a windup circle showing where it will expand to.
// Shows a brief effect at the end of the windup.
// Applies damage from attack.
// Starts cooldown timer.