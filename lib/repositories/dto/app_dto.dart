import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_dto.freezed.dart';
part 'app_dto.g.dart';

List<AppDto> appDtoFromJson(List<dynamic> data) =>
    List<AppDto>.from(data.map((x) => AppDto.fromJson(x)));

String appDtoToJson(List<AppDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@freezed
class AppDto with _$AppDto {
  const factory AppDto(
    String id,
    String appSecret,
    dynamic description,
    String displayName,
    String name,
    Os os,
    Platform platform,
    String origin,
    String iconUrl,
    DateTime createdAt,
    DateTime updatedAt,
    String releaseType,
    OwnerDto owner,
    @JsonKey(nullable: true) AzureSubscription? azureSubscription,
    List<MemberPermission> memberPermissions,
  ) = _AppDto;

  factory AppDto.fromJson(Map<String, dynamic> json) => _$AppDtoFromJson(json);
}

@freezed
class AzureSubscription with _$AzureSubscription {
  const factory AzureSubscription(
    String subscriptionId,
    String subscriptionName,
    String tenantId,
  ) = _AzureSubscription;

  factory AzureSubscription.fromJson(Map<String, dynamic> json) =>
      _$AzureSubscriptionFromJson(json);
}

enum MemberPermission { manager, developer }

enum Os {
  iOS,
  @JsonValue('Android')
  android
}

@freezed
class OwnerDto with _$OwnerDto {
  const factory OwnerDto(
    String id,
    String avatarUrl,
    String displayName,
    dynamic email,
    String name,
    Type type,
  ) = _OwnerDto;

  factory OwnerDto.fromJson(Map<String, dynamic> json) =>
      _$OwnerDtoFromJson(json);
}

enum Type { org }

enum Platform {
  @JsonValue('React-Native')
  reactNative,
  @JsonValue('Objective-C-Swift')
  objectiveCSwift,
}