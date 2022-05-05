// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_branch_dto.freezed.dart';

part 'build_branch_dto.g.dart';

@freezed
class BuildBranchDto with _$BuildBranchDto {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory BuildBranchDto({
    required String sourceVersion,
    @JsonKey(nullable: true) bool? debug,
  }) = _BuildBranchDto;

  factory BuildBranchDto.fromJson(Map<String, dynamic> json) =>
      _$BuildBranchDtoFromJson(json);
}
