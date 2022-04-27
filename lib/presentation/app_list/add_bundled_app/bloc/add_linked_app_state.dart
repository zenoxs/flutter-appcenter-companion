part of 'add_linked_app_cubit.dart';

@freezed
class AddLinkedAppState with _$AddLinkedAppState {
  factory AddLinkedAppState({
    @Default([]) List<Application> applications,
    Application? selectedApplication,
    @Default([]) List<Branch> branches,
    @Default(false) bool loadingBranches,
    Branch? selectedBranch,
  }) = _AddLinkedAppState;
}
