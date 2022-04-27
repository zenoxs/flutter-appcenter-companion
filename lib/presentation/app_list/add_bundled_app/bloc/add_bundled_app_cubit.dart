import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';
import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_bundled_app_cubit.freezed.dart';

part 'add_bundled_app_state.dart';

class AddBundledAppCubit extends Cubit<AddBundledAppState> {
  AddBundledAppCubit(
    ApplicationRepository applicationRepository,
    BranchRepository branchRepository,
  )   : _applicationRepository = applicationRepository,
        _branchRepository = branchRepository,
        super(AddBundledAppState()) {}

  final ApplicationRepository _applicationRepository;
  final BranchRepository _branchRepository;
}
