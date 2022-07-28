import 'package:test/test.dart';

import 'package:shimmer2_shared/ecs.dart';

class DummyComponent extends Component {
  final int value;

  DummyComponent(this.value);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

void main() {
  test('get/set component work', () {
    var world = World.empty();
    var entity = world.createEntity(ExecutionLocation.server);
    var component = DummyComponent(42);
    entity.setComponent(component);
    var gotten = entity.getComponent<DummyComponent>();
    expect(gotten, component);
  });
}
