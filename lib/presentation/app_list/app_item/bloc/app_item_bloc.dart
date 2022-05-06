import 'dart:async';

import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
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
  })
      : _store = store,
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

    _setupListeners();
  }

  final int _bundledApplicationId;
  final BundledApplicationRepository _bundledApplicationRepository;
  final BranchRepository _branchRepository;
  final Store _store;
  late final StreamSubscription _bundledApplicationSubscription;
  final Map<String, List<StreamSubscription>> _subscriptions = {};

  void _setupListeners() {
    final bundledApp = state.bundledApplication;
    final bundledAppSubName = 'bundledApp_${bundledApp.id}';

    void _onBundledAppChanged() {
      _subscriptions[bundledAppSubName]?.forEach((sub) => sub.cancel());
      _subscriptions[bundledAppSubName] = [];

      for (final linkedApp in state.bundledApplication.linkedApplications) {
        final linkedAppSubName = 'linkedApp_${linkedApp.id}';
        _subscriptions[linkedAppSubName] = [];

        void _onLinkedAppChanged() {
          _subscriptions[linkedAppSubName]?.forEach((sub) => sub.cancel());
          _subscriptions[linkedAppSubName] = [];

          final branch = linkedApp.branch.target!;
          final branchSubName = 'branch_${branch.id}';

          void _onBranchChanged() {
            _subscriptions[branchSubName]?.forEach((sub) => sub.cancel());
            _subscriptions[branchSubName] = [];

            final application = branch.application.target!;
            final applicationSub = _store
                .box<Application>()
                .query(Application_.id.equals(application.id))
                .watch()
                .doOnData(
                  (_) => add(AppItemEvent.updated()),
                ) //
                .listen((_) => {});
            _subscriptions[branchSubName]!.add(applicationSub);

            final lastBuild = branch.lastBuild.target;
            if (lastBuild != null) {
              final lastBuildSub = _store
                  .box<Build>()
                  .query(Build_.id.equals(lastBuild.id))
                  .watch()
                  .doOnData(
                    (_) => add(AppItemEvent.updated()),
                  ) //
                  .listen((_) => {});
              _subscriptions[branchSubName]!.add(lastBuildSub);
            }
          }

          final subBranch = _store
              .box<Branch>()
              .query(Branch_.id.equals(linkedApp.branch.target!.id))
              .watch()
              .doOnData(
                (_) => add(AppItemEvent.updated()),
              ) //
              .listen((_) => _onBranchChanged());
          _subscriptions[linkedAppSubName]!.add(subBranch);

          _onBranchChanged();
        }

        final subLinkedApp = _store
            .box<LinkedApplication>()
            .query(LinkedApplication_.id.equals(linkedApp.id))
            .watch()
            .doOnData(
              (_) => add(AppItemEvent.updated()),
            ) //
            .listen((_) => _onLinkedAppChanged());
        _subscriptions[bundledAppSubName]!.add(subLinkedApp);

        _onLinkedAppChanged();
      }
    }

    _bundledApplicationSubscription = _store
        .box<BundledApplication>()
        .query(BundledApplication_.id.equals(_bundledApplicationId))
        .watch()
        .distinct()
        .doOnData(
          (_) => add(AppItemEvent.updated()),
        ) //
        .listen((_) => _onBundledAppChanged());

    _onBundledAppChanged();
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

  void _onBuildRequested(
      AppItemEventBuildRequested event, Emitter<AppItemState> emit) {
    _branchRepository.build(event.linkedApplication.branch.target!);
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
