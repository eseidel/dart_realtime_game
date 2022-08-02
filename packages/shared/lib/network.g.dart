// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetJoinResponse _$NetJoinResponseFromJson(Map<String, dynamic> json) =>
    NetJoinResponse(
      json['matchId'] as int,
      json['playerId'] as int,
      json['heroId'] as int,
    );

Map<String, dynamic> _$NetJoinResponseToJson(NetJoinResponse instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'playerId': instance.playerId,
      'heroId': instance.heroId,
    };
