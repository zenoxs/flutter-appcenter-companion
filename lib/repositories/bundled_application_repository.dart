import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/entities/application.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'entities/bundled_application.dart';

class BundledApplicationRepository {
  BundledApplicationRepository(
    Store store,
    ApplicationRepository applicationRepository,
    AppcenterHttp http,
  )   : _store = store,
        _http = http,
        _applicationRepository = applicationRepository {
    _box = _store.box<BundledApplication>();
    bundledApplications.listen((event) {
      final bundledApplications = event.find();
      // listen to changes in bundles app to only listen to web socket events for the current bundle app
      // and not all of them
      // _connectWebSocket(bundledApplications);
    });
  }

  final Store _store;
  final AppcenterHttp _http;
  final ApplicationRepository _applicationRepository;
  late final Box<BundledApplication> _box;
  Map<int, WebSocketChannel> _applicationWSChannels = {};

  Stream<Query<BundledApplication>> get bundledApplications {
    // trigger the stream depends on relation too
    return Rx.combineLatest2(_box.query().watch(triggerImmediately: true),
        _store.box<Application>().query().watch(triggerImmediately: true),
        (Query<BundledApplication> bundleAppleQuery, _) {
      return bundleAppleQuery;
    });
  }

  _connectWebSocket(BundledApplication bundledApplication) async {
    for (final linkedApp in bundledApplication.linkedApplications) {
      final application = linkedApp.branch.target?.application.target;
      if (application != null) {
        final wsUrl = await _http.post(
            'apps/${application.owner.target!.name}/${application.name}/websockets');
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
        applications.map(_applicationRepository.fetchAppWithBranches));
  }

  Future<void> addBundledApplication(
      BundledApplication bundledApplication) async {
    _box.put(bundledApplication);
  }
}
