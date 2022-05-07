import 'dart:async';

import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'app_item_bloc.freezed.dart';
part 'app_item_event.dart';
part 'app_item_state.dart';

class AppItemBloc extends Bloc<AppItemEvent, AppItemState> {
  AppItemBloc({
    required int bundledApplicationId,
    required BundledApplicationRepository bundledApplicationRepository,
    required BranchRepository branchRepository,
    required Store store,
  })  : _store = store,
        _bundledApplicationId = bundledApplicationId,
        _branchRepository = branchRepository,
        _bundledApplicationRepository = bundledApplicationRepository,
        super(
          AppItemState(
            bundledApplication:
                store.box<BundledApplication>().get(bundledApplicationId)!,
            status: _buildStatus(store, bundledApplicationId),
            result: _buildResult(store, bundledApplicationId),
          ),
        ) {
    on<AppItemEventUpdated>(
      (event, emit) => _onBundledApplicationUpdated(emit),
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 100))
          .switchMap(mapper),
    );

    on<AppItemEventRemoveRequested>(
      (event, emit) => _onRemoveRequested(emit),
    );

    on<AppItemEventBuildRequested>(_onBuildRequested);
    on<AppItemEventCancelBuildRequested>(_onCancelBuildRequested);

    _setupListeners();
  }

  final int _bundledApplicationId;
  final BundledApplicationRepository _bundledApplicationRepository;
  final BranchRepository _branchRepository;
  final Store _store;
  late final StreamSubscription _bundledApplicationSubscription;
  final Map<String, List<StreamSubscription>> _subscriptions = {};

  void _watchItem<T>({
    Condition<T>? qc,
    VoidCallback? onChange,
    String? subName,
    String? dependsOn,
  }) {
    void _onChange() {
      if (subName != null) {
        _subscriptions[subName]?.forEach((sub) => sub.cancel());
        _subscriptions[subName] = [];
      }
      onChange?.call();
    }

    final sub = _store
        .box<T>()
        .query(qc)
        .watch()
        .doOnData(
          (_) => add(AppItemEvent.updated()),
        )
        .listen((_) => _onChange());

    _onChange();

    if (dependsOn != null) {
      _subscriptions[dependsOn]!.add(sub);
    }
  }

  void _setupListeners() {
    final bundledApp = state.bundledApplication;
    final bundledAppSubName = 'bundledApp_${bundledApp.id}';

    _watchItem<BundledApplication>(
      subName: bundledAppSubName,
      qc: BundledApplication_.id.equals(_bundledApplicationId),
      onChange: () {
        for (final linkedApp in state.bundledApplication.linkedApplications) {
          final linkedAppSubName = 'linkedApp_${linkedApp.id}';

          _watchItem<LinkedApplication>(
            subName: linkedAppSubName,
            qc: LinkedApplication_.id.equals(linkedApp.id),
            dependsOn: bundledAppSubName,
            onChange: () {
              final branch = linkedApp.branch.target!;
              final branchSubName = 'branch_${branch.id}';

              _watchItem<Branch>(
                qc: Branch_.id.equals(branch.id),
                subName: branchSubName,
                dependsOn: linkedAppSubName,
                onChange: () {
                  final application = branch.application.target!;
                  _watchItem<Application>(
                    qc: Application_.id.equals(application.id),
                    dependsOn: branchSubName,
                  );

                  final lastBuild = branch.lastBuild.target;
                  if (lastBuild != null) {
                    _watchItem<Build>(
                      qc: Build_.id.equals(lastBuild.id),
                      dependsOn: branchSubName,
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  static BuildResult _buildResult(Store store, int bundledApplicationId) {
    final bundledApp =
        store.box<BundledApplication>().get(bundledApplicationId)!;

    if (bundledApp.linkedApplications.any(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.result ==
          BuildResult.failed,
    )) {
      return BuildResult.failed;
    }

    if (bundledApp.linkedApplications.every(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.result ==
          BuildResult.succeeded,
    )) {
      return BuildResult.succeeded;
    }

    if (bundledApp.linkedApplications.every(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.result ==
          BuildResult.canceled,
    )) {
      return BuildResult.canceled;
    }

    return BuildResult.unknown;
  }

  static BuildStatus _buildStatus(Store store, int bundledApplicationId) {
    final bundledApp =
        store.box<BundledApplication>().get(bundledApplicationId)!;

    if (bundledApp.linkedApplications.any(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.status ==
          BuildStatus.inProgress,
    )) {
      return BuildStatus.inProgress;
    }

    if (bundledApp.linkedApplications.any(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.status ==
          BuildStatus.notStarted,
    )) {
      return BuildStatus.notStarted;
    }

    if (bundledApp.linkedApplications.any(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.status ==
          BuildStatus.cancelling,
    )) {
      return BuildStatus.cancelling;
    }

    if (bundledApp.linkedApplications.every(
      (linkedApp) =>
          linkedApp.branch.target!.lastBuild.target?.status ==
          BuildStatus.completed,
    )) {
      return BuildStatus.completed;
    }

    return BuildStatus.unknown;
  }

  void _onBundledApplicationUpdated(Emitter<AppItemState> emit) {
    emit(
      state.copyWith(
        bundledApplication: _store.box<BundledApplication>().get(
              _bundledApplicationId,
            )!,
        status: _buildStatus(_store, _bundledApplicationId),
        result: _buildResult(_store, _bundledApplicationId),
      ),
    );
  }

  void _onRemoveRequested(Emitter<AppItemState> emit) {
    _bundledApplicationRepository.remove(
      _bundledApplicationId,
    );
  }

  FutureOr<void> _onBuildRequested(
    AppItemEventBuildRequested event,
    Emitter<AppItemState> emit,
  ) {
    _branchRepository.build(event.linkedApplication.branch.target!);
  }

  FutureOr<void> _onCancelBuildRequested(
    AppItemEventCancelBuildRequested event,
    Emitter<AppItemState> emit,
  ) {
    _branchRepository.cancelBuild(event.linkedApplication.branch.target!);
  }

  void _cancelAllSubscriptions() {
    _subscriptions.forEach((key, value) {
      for (final sub in value) {
        sub.cancel();
      }
    });
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _bundledApplicationSubscription.cancel();
    _cancelAllSubscriptions();
    return super.close();
  }
}
