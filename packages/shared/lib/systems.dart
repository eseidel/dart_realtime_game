import 'ecs.dart';
import 'components.dart';
import 'geometry.dart';

class PhysicsSystem extends System {
  @override
  void update(World world, double dt) {
    for (final entity in world.query<DestinationComponent>().toList()) {
      final destination = entity.getComponent<DestinationComponent>();
      final physics = entity.getComponent<PhysicsComponent>();

      final delta = destination.location - physics.position;

      double speed = physics.speed * dt;
      // This makes it stop when it gets there.
      if (delta.length > speed) {
        entity.setComponent(physics.copyWith(
          angle: upVector.angleToSigned(delta),
          position: physics.position + delta.normalized() * speed,
        ));
      } else {
        // TODO: Do we want to queue mutations?
        entity.removeComponent<DestinationComponent>();
        entity.setComponent(physics.copyWith(position: destination.location));
      }
    }

    // For each skillshot component
    // Move move straight ahead at it's speed
    // Play forward its completion percentage.
    // Where are collision checks?
    // Does the shot stop on collision?
    // When 100% complete, remove the entity?
  }
}
