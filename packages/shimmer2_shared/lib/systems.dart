import 'ecs.dart';
import 'components.dart';
import 'geometry.dart';

class PhysicsSystem extends System {
  @override
  void update(World world, double dt) {
    for (final entity in world.query<DestinationComponent>()) {
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
        entity.removeComponent<DestinationComponent>();
        entity.setComponent(physics.copyWith(position: destination.location));
      }
    }
  }
}
