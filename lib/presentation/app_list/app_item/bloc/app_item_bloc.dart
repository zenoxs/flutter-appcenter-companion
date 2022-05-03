import 'dart:async';

import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'app_item_bloc.freezed.dart';

part 'app_item_event.dart';

part 'app_item_state.dart';

class AppItemBloc extends Bloc<AppItemEvent, AppItemState> {
  AppItemBloc({
    required int bundledApplicationId,
    required Store store,
  })  : _store = store,
        _bundledApplicationId = bundledApplicationId,
        super(
          AppItemState(
            bundledApplication:
                store.box<BundledApplication>().get(bundledApplicationId)!,
          ),
        ) {
    on<AppItemEventUpdated>(
      (event, emit) => _onBundledApplicationUpdated(emit),
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 100))
          .switchMap(mapper),
    );

    _setupListeners();
  }

  final int _bundledApplicationId;
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

  void _onBundledApplicationUpdated(Emitter<AppItemState> emit) {
    emit(
      state.copyWith(
        bundledApplication: _store.box<BundledApplication>().get(
              _bundledApplicationId,
            )!,
      ),
    );
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
