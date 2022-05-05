part of 'new_release_cubit.dart';

@freezed
class NewReleaseState with _$NewReleaseState {
  factory NewReleaseState.initial() = NewReleaseStateInitial;

  factory NewReleaseState.availableVersion({
    required String version,
    required String url,
    @Default(false) bool currentReleaseIgnored,
  }) = NewReleaseStateAvailableVersion;
}
