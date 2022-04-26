import 'package:appcenter_companion/objectbox.g.dart';

import 'entities/bundled_application.dart';

class BundledApplicationRepository {
  BundledApplicationRepository(
    Store store,
  ) : _store = store {
    _box = _store.box<BundledApplication>();
  }

  final Store _store;
  late final Box<BundledApplication> _box;

  Stream<Query<BundledApplication>> get bundledApplications {
    return _box.query().watch();
  }

  Future<void> addBundledApplication(
      BundledApplication bundledApplication) async {
    _box.put(bundledApplication);
  }
}
