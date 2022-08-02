import 'package:test/test.dart';

import 'package:shared/ecs.dart';

class DummyComponent extends Component {
  final int value;

  DummyComponent(this.value);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

void main() {
  test('get/set component', () {
    var world = World.empty();
    var entity = world.createEntity(ExecutionLocation.server);
    var component = DummyComponent(42);
    entity.setComponent(component);
    var gotten = entity.getComponent<DummyComponent>();
    expect(gotten, component);
  });

  test('destroy entity destroys components', () {
    var world = World.empty();
    var entity = world.createEntity(ExecutionLocation.server);
    var component = DummyComponent(42);
    entity.setComponent(component);
    var gotten = entity.getComponent<DummyComponent>();
    expect(gotten, component);
    expect(world.entities.length, 1);
    expect(world.components.length, 1);

    world.destroyEntity(entity);
    expect(world.entities.length, 0);
    expect(world.components.length, 1);
    expect(world.components[DummyComponent]!.isEmpty, true);
  });

  test('entity queries', () {
    var world = World.empty();
    var entity = world.createEntity(ExecutionLocation.server);
    var component = DummyComponent(42);
    entity.setComponent(component);

    var query = world.query<DummyComponent>();
    expect(query.length, 1);
    expect(query.first, entity);
    expect(entity.getComponent<DummyComponent>(), component);
  });
}
