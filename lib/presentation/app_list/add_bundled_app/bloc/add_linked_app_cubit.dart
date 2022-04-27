import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';
import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_linked_app_cubit.freezed.dart';

part 'add_linked_app_state.dart';

class AddLinkedAppCubit extends Cubit<AddLinkedAppState> {
  AddLinkedAppCubit(ApplicationRepository applicationRepository,
      BranchRepository branchRepository,)
      : _applicationRepository = applicationRepository,
        _branchRepository = branchRepository,
        super(AddLinkedAppState()) {
    applicationRepository.applications.listen((event) {
      emit(state.copyWith(applications: event.find()));
    });
  }

  final ApplicationRepository _applicationRepository;
  final BranchRepository _branchRepository;

  Future<void> selectApplication(Application application) async {
    emit(
      state.copyWith(
        selectedApplication: application,
        selectedBranch: null,
        branches: [],
      ),
    );
  }

  Future<void> selectBranch(Branch branch) async {
    emit(
      state.copyWith(
        selectedBranch: branch,
      ),
    );
  }
}
