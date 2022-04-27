import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';

import 'dto/dto.dart';
import 'entities/entities.dart';

class BranchRepository {
  BranchRepository(
    AppcenterHttp http,
    Store store,
  )   : _http = http,
        _store = store {
    _box = _store.box<Branch>();
  }

  final AppcenterHttp _http;
  final Store _store;
  late final Box<Branch> _box;

  Stream<Query<Branch>> get branches {
    return _box.query().watch(triggerImmediately: true);
  }

  Future<List<Branch>> fetchBranchByApplication(Application application) async {
    final dtoAppBranches = await _http
        .get('${application.owner.target!.name}/${application.name}/branches')
        .then((value) => branchDtoFromJson(value.data));

    final List<Branch> appBranches = [];
    _store.runInTransaction(TxMode.write, () {
      for (final dtoBranch in dtoAppBranches) {
        final branch = Branch.createFromDto(dtoBranch, application, _store);
        appBranches.add(branch);
      }
    });

    return appBranches;
  }
}
