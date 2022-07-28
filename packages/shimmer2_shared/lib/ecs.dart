import 'package:meta/meta.dart';

import 'components.dart';

typedef EntityId = int;

enum ExecutionLocation { client, server }

class World {
  // FIXME: Server and client need to start at different id offsets.
  // Otherwise when the client makes speculative entities they mihgt collide
  // with real server entity ids.
  int _nextId = 0;
  static const int speculativeEntityOffset = 6400000;
  Set<Entity> entities = {};
  Map<Type, Map<EntityId, Component>> components = {};

  World.empty() {
    _nextId = 0;
  }

  int allocateEntityId(ExecutionLocation location) {
    final id = _nextId++;
    if (id >= speculativeEntityOffset) {
      throw Exception('Too many entities in the world.');
    }
    switch (location) {
      case ExecutionLocation.client:
        return id + speculativeEntityOffset;
      case ExecutionLocation.server:
        return id;
    }
  }

  Entity createEntity(ExecutionLocation location) {
    final entity = Entity(world: this, id: allocateEntityId(location));
    entities.add(entity);
    return entity;
  }

  void destroyEntity(Entity entity) {
    entities.remove(entity);
    for (final entry in components.entries) {
      entry.value.remove(entity.id);
    }
  }

  Entity getEntity(EntityId id) => Entity(world: this, id: id);

  Iterable<Entity> query<T>() {
    return (components[T.runtimeType] ?? {})
        .keys
        .map((id) => Entity(world: this, id: id));
  }

  Map<String, dynamic> toJson() {
    return {
      'entities': entities.map((e) => e.toJson()).toList(),
      'components': {
        for (final componentEntry in components.entries)
          componentEntry.key.toString(): {
            for (final entry in componentEntry.value.entries)
              entry.key.toString(): entry.value.toJson(),
          },
      },
    };
  }

  void applySnapshot(Map<String, dynamic> worldSnapshot) {
    // TODO: We should be applying a patch rather than a full snapshot.
    entities.clear();
    components.clear();

    entities.addAll(worldSnapshot['entities']
        .map<Entity>((id) => Entity(world: this, id: int.parse(id))));
    for (final componentEntry in worldSnapshot['components'].entries) {
      final componentTypeName = componentEntry.key;
      final deserializer = kComponentDeserializers[componentTypeName];
      if (deserializer == null) {
        throw Exception('Unknown component type: $componentTypeName');
      }
      final type = kComponentTypes[componentTypeName]!;
      components[type] = {
        for (final entry in componentEntry.value.entries)
          int.parse(entry.key): deserializer(entry.value),
      };
    }
  }
}

class Entity {
  final World world;
  final EntityId id;

  Entity({
    required this.world,
    required this.id,
  });

  T getComponent<T extends Component>() {
    return world.components[T]?[id] as T;
  }

  void setComponent(Component component) {
    world.components.putIfAbsent(component.runtimeType, () => {})[id] =
        component;
  }

  void removeComponent<T extends Component>() {
    world.components[T]?.remove(id);
  }

  String toJson() => id.toString();
}

@immutable
abstract class Component {
  const Component();

  Map<String, dynamic> toJson();
}

abstract class System {
  const System();

  void update(World world, double dt);
}
