import 'package:appcenter_companion/repositories/bundled_application_repository.dart';
import 'package:appcenter_companion/repositories/entities/branch.dart';
import 'package:appcenter_companion/repositories/entities/bundled_application.dart';
import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bundled_app_cubit.freezed.dart';
part 'bundled_app_state.dart';

class BundledAppCubit extends Cubit<BundledAppState> {
  BundledAppCubit(BundledApplicationRepository bundledApplicationRepository)
      : _bundledApplicationRepository = bundledApplicationRepository,
        super(BundledAppState()) {
    bundledApplicationRepository.bundledApplications.listen((event) {
      final apps = event.find();
      emit(state.copyWith(bundledApplications: apps));
    });
  }

  final BundledApplicationRepository _bundledApplicationRepository;

  void addBundledApp(String name, List<Branch> linkedBranches) {
    final bundledApplication = BundledApplication(name: name);
    for (final branch in linkedBranches) {
      final linkedApplication = LinkedApplication();
      linkedApplication.branch.target = branch;
      bundledApplication.linkedApplications.add(linkedApplication);
    }
    _bundledApplicationRepository.addBundledApplication(bundledApplication);
  }
}
