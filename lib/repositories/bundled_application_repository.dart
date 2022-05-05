import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/app_websocket_channel.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:rxdart/rxdart.dart';

import 'dto/dto.dart';
import 'entities/entities.dart';

class BundledApplicationRepository {
  BundledApplicationRepository(
    Store store,
    ApplicationRepository applicationRepository,
    AppcenterHttp http,
  )   : _store = store,
        _http = http,
        _applicationRepository = applicationRepository {
    _box = _store.box<BundledApplication>();
    _box
        .query()
        .watch(triggerImmediately: true)
        .debounceTime(
          const Duration(seconds: 1),
        ) // debounce to avoid spamming channel creation
        .listen((event) {
      debugPrint('connect WS');
      final bundledApps = event.find();
      // listen to changes in bundles app to only listen to web socket events for the current bundle app
      // and not all of them
      _disconnectAllWebSocket();
      for (final bundledApp in bundledApps) {
        _connectWebSocket(bundledApp);
      }
    });
  }

  final Store _store;
  final AppcenterHttp _http;
  final ApplicationRepository _applicationRepository;
  late final Box<BundledApplication> _box;
  final List<AppWebSocketChannel> _applicationWSChannels = [];

  Box<BundledApplication> get box => _box;

  Stream<Query<BundledApplication>> get bundledApplications {
    // trigger the stream depends on relation too
    // return Rx.combineLatest3(
    //     _box.query().watch(triggerImmediately: true),
    //     _store.box<Application>().query().watch(triggerImmediately: true),
    //     _store.box<Branch>().query().watch(triggerImmediately: true),
    //     (Query<BundledApplication> bundleAppleQuery, _, __) {
    //   return bundleAppleQuery;
    // });
    return _box.query().watch(triggerImmediately: true);
  }

  void _disconnectAllWebSocket() {
    for (final channel in _applicationWSChannels) {
      channel.close();
    }
    _applicationWSChannels.clear();
  }

  Future<void> _connectWebSocket(BundledApplication bundledApplication) async {
    for (final linkedApp in bundledApplication.linkedApplications) {
      final application = linkedApp.branch.target?.application.target;
      if (application != null) {
        final appWebSocket = await AppWebSocketChannel.connect(
          http: _http,
          linkedApplication: linkedApp,
        );

        appWebSocket.event.listen((event) {
          if (event is WsAppEventBuild) {
            final branch = linkedApp.branch.target!;
            final build = Build.createFromDto(
              event.data,
              branch,
              _store,
            );
            branch.lastBuild.target = build;
            _store.box<Branch>().put(branch);
          }
        });
        _applicationWSChannels.add(appWebSocket);
      }
    }
  }

  Future<void> refresh() async {
    final bundledApps =
        await bundledApplications.first.then((value) => value.find());
    final applications =
        bundledApps.fold<List<Application>>([], (value, element) {
      for (final linkedApp in element.linkedApplications) {
        final app = linkedApp.branch.target!.application.target;
        if (app != null && !value.contains(app)) {
          value.add(app);
        }
      }
      return value;
    });
    await Future.wait(
      applications.map(_applicationRepository.fetchWithBranches),
    );
  }

  Future<void> add(
    BundledApplication bundledApplication,
  ) async {
    _box.put(bundledApplication);
  }

  void remove(int bundledApplicationId) {
    _box.remove(bundledApplicationId);
  }
}
