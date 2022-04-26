import 'package:appcenter_companion/repositories/appcenter_http.dart';

import 'dto/app_dto.dart';

class ApplicationRepository {
  ApplicationRepository(AppcenterHttp http) : _http = http;

  final AppcenterHttp _http;

  Future<List<AppDto>> apps() {
    return _http.get('apps').then((value) => appDtoFromJson(value.data));
  }
}
