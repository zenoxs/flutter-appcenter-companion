import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_release.freezed.dart';

@freezed
class NewRelease with _$NewRelease {
  const factory NewRelease({
    required String version,
    required String downloadUrl,
  }) = _NewRelease;
}
