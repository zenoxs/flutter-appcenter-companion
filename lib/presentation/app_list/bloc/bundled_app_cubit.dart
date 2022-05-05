import 'dart:async';

import 'package:appcenter_companion/repositories/authentication_repository.dart';
import 'package:appcenter_companion/repositories/bundled_application_repository.dart';
import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bundled_app_cubit.freezed.dart';
part 'bundled_app_state.dart';

class BundledAppCubit extends Cubit<BundledAppState> {
  BundledAppCubit(
    BundledApplicationRepository bundledApplicationRepository,
    AuthenticationRepository authenticationRepository,
  )   : _bundledApplicationRepository = bundledApplicationRepository,
        super(BundledAppState()) {
    _bundledApplicationSubscription =
        bundledApplicationRepository.bundledApplications.listen((event) {
      final apps = event.find();
      emit(state.copyWith(bundledApplications: apps));
    });
    authenticationRepository.stream
        .firstWhere((auth) => auth is AuthenticationStateAuthenticated)
        .then((_) {
      refresh();
    });
  }

  final BundledApplicationRepository _bundledApplicationRepository;
  late final StreamSubscription _bundledApplicationSubscription;

  StreamSubscription<void>? refreshDataSubscription;

  void addBundledApp(String name, List<Branch> linkedBranches) {
    final bundledApplication = BundledApplication(name: name);
    for (final branch in linkedBranches) {
      final linkedApplication = LinkedApplication();
      linkedApplication.branch.target = branch;
      bundledApplication.linkedApplications.add(linkedApplication);
    }
    _bundledApplicationRepository.add(bundledApplication);
  }

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));
    refreshDataSubscription?.cancel();
    refreshDataSubscription = _bundledApplicationRepository
        .refresh()
        .whenComplete(() => emit(state.copyWith(loading: false)))
        .asStream()
        .listen((_) {});
  }

  @override
  Future<void> close() {
    _bundledApplicationSubscription.cancel();
    refreshDataSubscription?.cancel();
    return super.close();
  }
}
