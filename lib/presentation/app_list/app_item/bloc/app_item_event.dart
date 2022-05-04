part of 'app_item_bloc.dart';

@freezed
class AppItemEvent with _$AppItemEvent {
  factory AppItemEvent.updated() = AppItemEventUpdated;

  factory AppItemEvent.removeRequested() = AppItemEventRemoveRequested;

  factory AppItemEvent.buildAllRequested() = AppItemEventBuildAllRequested;

  factory AppItemEvent.cancelAllBuildRequested() =
      AppItemEventCancelAllBuildRequested;
}
