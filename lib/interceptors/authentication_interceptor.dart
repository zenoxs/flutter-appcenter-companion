import 'package:appcenter_companion/repositories/authentication_repository.dart';
import 'package:dio/dio.dart';

class AuthenticationInterceptor extends InterceptorsWrapper {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationInterceptor(this._authenticationRepository) : super();

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    handler.next(await _addToken(options));
  }

  Future<RequestOptions> _addToken(RequestOptions options) async {
    final auth = await _authenticationRepository.stream.first;
    if (auth is AuthenticationStateAuthenticated) {
      options.headers['x-api-token'] = auth.token;
    }

    return options;
  }
}
