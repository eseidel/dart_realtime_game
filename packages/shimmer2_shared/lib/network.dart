import 'geometry.dart';
import 'ecs.dart';

import 'package:json_annotation/json_annotation.dart';

part 'network.g.dart';

@JsonSerializable()
class NetJoinResponse {
  final EntityId matchId;
  final EntityId playerId;
  final EntityId heroId;

  const NetJoinResponse(this.matchId, this.playerId, this.heroId);

  factory NetJoinResponse.fromJson(Map<String, dynamic> json) =>
      _$NetJoinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NetJoinResponseToJson(this);
}

class ServerUpdate {
  final int tickNumber;
  final Map<String, dynamic> worldSnapshot;

  const ServerUpdate({
    required this.tickNumber,
    required this.worldSnapshot,
  });

  Map<String, dynamic> toJson() => {
        'tickNumber': tickNumber,
        'worldSnapshot': worldSnapshot,
      };

  ServerUpdate.fromJson(Map<String, dynamic> json)
      : tickNumber = json['tickNumber'],
        worldSnapshot = json['worldSnapshot'];
}
