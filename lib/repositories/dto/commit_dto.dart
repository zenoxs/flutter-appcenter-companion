// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_dto.freezed.dart';

part 'commit_dto.g.dart';

@freezed
abstract class BranchCommitDto with _$BranchCommitDto {
  const factory BranchCommitDto(
    String sha,
    @JsonKey(nullable: true) CommitDto? commit,
      @JsonKey(nullable: true) AuthorAvatarDto? author,) = _BranchCommitDto;

  factory BranchCommitDto.fromJson(Map<String, dynamic> json) =>
      _$BranchCommitDtoFromJson(json);
}

@freezed
abstract class AuthorAvatarDto with _$AuthorAvatarDto {
  const factory AuthorAvatarDto(String avatarUrl,) = _AuthorAvatarDto;

  factory AuthorAvatarDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorAvatarDtoFromJson(json);
}

@freezed
abstract class CommitDto with _$CommitDto {
  const factory CommitDto(String message,
      CommitAuthorDto author,) = _CommitDto;

  factory CommitDto.fromJson(Map<String, dynamic> json) =>
      _$CommitDtoFromJson(json);
}

@freezed
abstract class CommitAuthorDto with _$CommitAuthorDto {
  const factory CommitAuthorDto(DateTime date,
      String name,
      String email,) = _CommitAuthorDto;

  factory CommitAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$CommitAuthorDtoFromJson(json);
}
