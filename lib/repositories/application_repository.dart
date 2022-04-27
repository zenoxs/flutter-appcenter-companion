import 'package:appcenter_companion/bloc/authentication/authentication_cubit.dart';
import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';

import 'dto/dto.dart';
import 'entities/application.dart';

class ApplicationRepository {
  ApplicationRepository(
      AppcenterHttp http, Store store, AuthenticationCubit authenticationCubit)
      : _http = http,
        _store = store {
    _box = _store.box<Application>();
    authenticationCubit.stream.distinct().listen((state) {
      if (state is AuthenticationStateAuthenticated) {
        fetchAllApps();
      }
    });
  }

  final AppcenterHttp _http;
  final Store _store;
  late final Box<Application> _box;

  Stream<Query<Application>> get applications {
    return _box.query().watch(triggerImmediately: true);
  }

  Future<void> fetchAllApps() async {
    final apps =
        await _http.get('apps').then((value) => appDtoFromJson(value.data));

    _store.runInTransaction(TxMode.write, () {
      for (final app in apps) {
        Application.createFromDto(app, _store);
      }
    });
  }
}
