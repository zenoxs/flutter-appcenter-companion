import 'package:appcenter_companion/repositories/token_repository.dart';
import 'package:dio/dio.dart';

class AuthenticationInterceptor extends InterceptorsWrapper {
  final TokenRepository _tokenRepository;

  AuthenticationInterceptor(this._tokenRepository) : super();

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    handler.next(await _addToken(options));
  }

  Future<RequestOptions> _addToken(RequestOptions options) async {
    final token = await _tokenRepository.token.first;
    if (token != null) {
      options.headers['x-api-token'] = token;
    }

    return options;
  }
}
