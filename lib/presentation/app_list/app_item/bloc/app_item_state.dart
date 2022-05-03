part of 'app_item_bloc.dart';

@freezed
class AppItemState with _$AppItemState {
  factory AppItemState({
    required BundledApplication bundledApplication,
  }) = _AppItemState;
}
