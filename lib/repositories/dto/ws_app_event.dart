// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'build_dto.dart';

part 'ws_app_event.freezed.dart';

part 'ws_app_event.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
class WsAppEvent with _$WsAppEvent {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory WsAppEvent.buildUpdated(BuildDto data) = WsAppEventBuild;

  @JsonSerializable(fieldRename: FieldRename.none)
  const factory WsAppEvent.logConsoleLines(int buildId, dynamic data) =
  WsAppEventLogConsoleLines;

  factory WsAppEvent.fromJson(Map<String, dynamic> json) =>
      _$WsAppEventFromJson(json);
}
