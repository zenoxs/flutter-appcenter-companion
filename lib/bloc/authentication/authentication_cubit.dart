import 'dart:async';

import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/token_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_cubit.freezed.dart';
part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(
    AppcenterHttp http,
    TokenRepository tokenRepository,
  )   : _tokenRepository = tokenRepository,
        _http = http,
        super(const AuthenticationState.unknown()) {
    _authenticationTokenSubscription =
        _tokenRepository.token.listen(_onAuthenticationTokenChanged);
  }

  final TokenRepository _tokenRepository;
  final AppcenterHttp _http;
  late StreamSubscription<String?> _authenticationTokenSubscription;

  Future<void> _onAuthenticationTokenChanged(
    String? token,
  ) async {
    if (token != null) {
      emit(AuthenticationState.authenticated(token: token));
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> login(String token) async {
    _tokenRepository.clearToken();
    final isValid = await _http.checkTokenValidity(token);
    if (isValid) {
      _tokenRepository.setToken(token);
    }
  }

  Future<void> logOut(String token) async {
    _tokenRepository.clearToken();
  }

  @override
  Future<void> close() {
    _authenticationTokenSubscription.cancel();
    _tokenRepository.dispose();
    return super.close();
  }
}
