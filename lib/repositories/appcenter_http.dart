import 'package:appcenter_companion/environment.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

class AppcenterHttp extends DioForNative {
  AppcenterHttp(Environment environment)
      : super(
          BaseOptions(baseUrl: environment.appcenterApiUrl),
        );
}
