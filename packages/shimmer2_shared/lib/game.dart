import 'package:shimmer2_shared/components.dart';

import 'dart:math';

import 'geometry.dart';
import 'network.dart';
import 'ecs.dart';
import 'systems.dart';

// Immutable GameState
// class GameState {
//   final int tickNumber;
//   final DateTime? clientTime;

//   final List<Entity> entities;

//   GameState({
//     required this.tickNumber,
//     required this.entities,
//     this.clientTime,
//   });

//   // GameState playedForward(Duration delta) {
//   //   var newEntities = List<Entity>.from(entities);
//   //   // If delta is more than tick time, we need to play multiple ticks.
//   //   for (var entity in newEntities) {
//   //     entity.update(delta.inMilliseconds / 1000);
//   //   }
//   //   return GameState(
//   //     // Should this have a tick number?
//   //     tickNumber: tickNumber + 1,
//   //     entities: newEntities,
//   //     clientTime: DateTime.now(),
//   //   );
//   // }

//   GameState.fromNet(NetGameState net)
//       : tickNumber = net.tickNumber,
//         clientTime = DateTime.now(),
//         entities = net.entities.map((e) => Entity.fromNet(e)).toList();
// }

// Mutable Game
// Game and GameState could be combined?
class Game {
  int tickNumber = 0;
  Duration tickDuration;
  final World world = World.empty(perTickSystems: [PhysicsSystem()]);
  late final Entity match;
  final random = Random();

  Game({required int ticksPerSecond})
      : tickDuration = Duration(milliseconds: 1000 ~/ ticksPerSecond) {
    match = world.createEntity(ExecutionLocation.server);
    match.setComponent(MapComponent(size: Vector2(200, 200)));
  }

  Vector2 randomPosition() {
    final map = match.getComponent<MapComponent>();
    return Vector2(
        map.size.x * random.nextDouble(), map.size.y * random.nextDouble());
  }

  double secondsPerTick() => tickDuration.inMilliseconds / 1000;

  ServerUpdate toNet() => ServerUpdate(
        tickNumber: tickNumber,
        worldSnapshot: world.toJson(),
      );

  void tick() {
    tickNumber++;
    world.runSystems(world.perTickSystems, tickDuration);
  }
}
