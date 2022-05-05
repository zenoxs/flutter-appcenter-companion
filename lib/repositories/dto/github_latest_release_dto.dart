// ignore_for_file: avoid_positional_boolean_parameters

import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_latest_release_dto.freezed.dart';

part 'github_latest_release_dto.g.dart';

@freezed
class GitHubLatestReleaseDto with _$GitHubLatestReleaseDto {
  const factory GitHubLatestReleaseDto(
    String url,
    String assetsUrl,
    String uploadUrl,
    String htmlUrl,
    int id,
    GitHubAuthorDto author,
    String nodeId,
    String tagName,
    String targetCommitish,
    String name,
    bool draft,
    bool prerelease,
    DateTime createdAt,
    DateTime publishedAt,
    List<GitHubAssetDto> assets,
    String tarballUrl,
    String zipballUrl,
    String body,
  ) = _GitHubLatestReleaseDto;

  factory GitHubLatestReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$GitHubLatestReleaseDtoFromJson(json);
}

@freezed
abstract class GitHubAssetDto with _$GitHubAssetDto {
  const factory GitHubAssetDto(
    String url,
    int id,
    String nodeId,
    String name,
    String label,
    GitHubAuthorDto uploader,
    String contentType,
    String state,
    int size,
    int downloadCount,
    DateTime createdAt,
    DateTime updatedAt,
    String browserDownloadUrl,
  ) = _GitHubAssetDto;

  factory GitHubAssetDto.fromJson(Map<String, dynamic> json) =>
      _$GitHubAssetDtoFromJson(json);
}

@freezed
class GitHubAuthorDto with _$GitHubAuthorDto {
  const factory GitHubAuthorDto(
    String login,
    int id,
    String nodeId,
    String avatarUrl,
    String gravatarId,
    String url,
    String htmlUrl,
    String followersUrl,
    String followingUrl,
    String gistsUrl,
    String starredUrl,
    String subscriptionsUrl,
    String organizationsUrl,
    String reposUrl,
    String eventsUrl,
    String receivedEventsUrl,
    String type,
    bool siteAdmin,
  ) = _GitHubAuthorDto;

  factory GitHubAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$GitHubAuthorDtoFromJson(json);
}
