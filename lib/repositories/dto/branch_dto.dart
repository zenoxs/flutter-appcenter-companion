import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'build_dto.dart';
import 'commit_dto.dart';

part 'branch_dto.freezed.dart';
part 'branch_dto.g.dart';

List<BranchDto> branchDtoFromJson(List<dynamic> data) =>
    List<BranchDto>.from(data.map((x) => BranchDto.fromJson(x)));

String branchDtoToJson(List<BranchDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@freezed
abstract class BranchDto with _$BranchDto {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory BranchDto(BranchValueDto branch,
      bool configured,
      @JsonKey(nullable: true) BuildDto? lastBuild,
      @JsonKey(nullable: true) String? trigger,) = _BranchDto;

  factory BranchDto.fromJson(Map<String, dynamic> json) =>
      _$BranchDtoFromJson(json);
}

@freezed
abstract class BranchValueDto with _$BranchValueDto {
  const factory BranchValueDto(
    String name,
    BranchCommitDto commit,
  ) = _BranchValueDto;

  factory BranchValueDto.fromJson(Map<String, dynamic> json) =>
      _$BranchValueDtoFromJson(json);
}
