// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_method.freezed.dart';

part 'ws_method.g.dart';

@Freezed(unionKey: 'method', unionValueCase: FreezedUnionCase.kebab)
class WsMethod with _$WsMethod {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory WsMethod.watchRepo() = WsMethodWatchRepo;

  @JsonSerializable(fieldRename: FieldRename.none)
  const factory WsMethod.subscribe(int buildId) = WsMethodSubscribe;

  factory WsMethod.fromJson(Map<String, dynamic> json) =>
      _$WsMethodFromJson(json);
}
