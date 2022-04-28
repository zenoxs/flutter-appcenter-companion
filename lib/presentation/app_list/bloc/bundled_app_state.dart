part of 'bundled_app_cubit.dart';

@freezed
class BundledAppState with _$BundledAppState {
  factory BundledAppState({
    @Default([]) List<BundledApplication> bundledApplications,
    @Default(false) bool loading,
  }) = _BundledAppState;
}
