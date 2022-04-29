import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_bundled_app_cubit.freezed.dart';
part 'add_bundled_app_state.dart';

class AddBundledAppCubit extends Cubit<AddBundledAppState> {
  AddBundledAppCubit() : super(AddBundledAppState());

  void addLinkedBranch(Branch branch) {
    emit(state.copyWith(linkedBranches: state.linkedBranches + [branch]));
  }
}
