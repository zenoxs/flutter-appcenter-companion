import 'package:freezed_annotation/freezed_annotation.dart';

import 'build_dto.dart';

part 'ws_app_event.freezed.dart';

part 'ws_app_event.g.dart';

@freezed
class BuildUpdatedData with _$BuildUpdatedData {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory BuildUpdatedData(
    int id,
    String buildNumber,
    DateTime queueTime,
    DateTime lastChangedDate,
    BuildStatus status,
    String reason,
    String sourceBranch,
    String sourceVersion,
  ) = _BuildUpdatedData;

  factory BuildUpdatedData.fromJson(Map<String, dynamic> json) =>
      _$BuildUpdatedDataFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
class WsAppEvent with _$WsAppEvent {
  const factory WsAppEvent() = WsAppEventData;

  @JsonSerializable(fieldRename: FieldRename.none)
  const factory WsAppEvent.buildUpdated(BuildUpdatedData data) =
      WsAppEventSpecial;

  factory WsAppEvent.fromJson(Map<String, dynamic> json) =>
      _$WsAppEventFromJson(json);
}
