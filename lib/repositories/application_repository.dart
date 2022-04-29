import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';

import 'dto/dto.dart';
import 'entities/application.dart';

class ApplicationRepository {
  ApplicationRepository(
    AppcenterHttp http,
    Store store,
    BranchRepository branchRepository,
  )   : _http = http,
        _store = store,
        _branchRepository = branchRepository {
    _box = _store.box<Application>();
  }

  final AppcenterHttp _http;
  final BranchRepository _branchRepository;
  final Store _store;
  late final Box<Application> _box;

  Stream<Query<Application>> get applications {
    return _box.query().watch(triggerImmediately: true);
  }

  Future<Application> fetchAppWithBranches(Application application) async {
    final appDto = await _http
        .get('apps/${application.owner.target!.name}/${application.name}')
        .then((res) => AppDto.fromJson(res.data));
    final app = Application.createFromDto(appDto, _store);
    await _branchRepository.fetchBranchByApplication(app);
    return app;
  }

  Future<List<Application>> fetchAllApps() async {
    final dtoApps =
        await _http.get('apps').then((value) => appDtoFromJson(value.data));

    final List<Application> apps = [];
    _store.runInTransaction(TxMode.write, () {
      for (final dtoApp in dtoApps) {
        final app = Application.createFromDto(dtoApp, _store);
        apps.add(app);
      }
    });

    return apps;
  }
}
