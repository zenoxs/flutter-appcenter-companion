import 'package:appcenter_companion/environment.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

class AppcenterHttp extends DioForNative {
  AppcenterHttp(Environment environment)
      : super(
          BaseOptions(baseUrl: environment.appcenterApiUrl),
        );

  Future<bool> checkTokenValidity(String token) async {
    return get(
      'user',
      options: Options(
        headers: {
          'content-type': 'application/json',
          'x-api-token': token,
        },
      ),
    ).then((value) {
      return value.data != null;
    }).catchError((error) {
      return false;
    });
  }
}
