import 'dart:async';

import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:dio/dio.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final AppcenterHttp _http;

  AuthenticationRepository(AppcenterHttp http) : _http = http;

  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String token,
  }) async {
    _http.get(
      'user/metadata/optimizely',
      options: Options(
        headers: {
          'X-API-Token': token,
        },
      ),
    );
    _controller.add(AuthenticationStatus.authenticated);
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
