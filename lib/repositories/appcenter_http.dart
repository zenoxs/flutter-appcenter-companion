import 'package:appcenter_companion/environment.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

class AppcenterHttp extends DioForNative {
  AppcenterHttp(Environment environment)
      : super(
          BaseOptions(baseUrl: environment.appcenterApiUrl),
        );

  Future<bool> checkTokenValidity(String token) async {
    final data = await get(
      'user/metadata/optimizely',
      options: Options(
        headers: {
          'X-API-Token': token,
        },
      ),
    );
    print(data);
    return data.statusCode == 200;
  }
}
