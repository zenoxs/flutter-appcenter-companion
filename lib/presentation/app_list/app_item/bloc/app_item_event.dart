part of 'app_item_bloc.dart';

@freezed
class AppItemEvent with _$AppItemEvent {
  factory AppItemEvent.updated() = AppItemEventUpdated;
}
