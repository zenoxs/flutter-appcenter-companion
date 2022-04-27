part of 'add_bundled_app_cubit.dart';

@freezed
class AddBundledAppState with _$AddBundledAppState {
  factory AddBundledAppState({
    @Default([]) List<Branch> linkedBranches,
  }) = _AddBundledAppState;
}
