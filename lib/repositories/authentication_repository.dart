import 'dart:async';
import 'dart:convert';

import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'storage_repository.dart';

part 'authentication_repository.freezed.dart';
part 'authentication_repository.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.authenticated({
    required String token,
    @Default(AuthenticationAccess.readOnly) AuthenticationAccess access,
  }) = AuthenticationStateAuthenticated;

  const factory AuthenticationState.unauthenticated() =
      AuthenticationStateUnauthenticated;

  const factory AuthenticationState.unknown() = AuthenticationStateUnknown;

  factory AuthenticationState.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationStateFromJson(json);
}

enum AuthenticationAccess {
  fullAccess,
  readOnly,
}

extension AuthenticationHelpers on AuthenticationState {
  bool get isConnected {
    return this is AuthenticationStateAuthenticated;
  }

  bool get isFullAccess {
    return this is AuthenticationStateAuthenticated &&
        (this as AuthenticationStateAuthenticated).access ==
            AuthenticationAccess.fullAccess;
  }
}

class AuthenticationRepository {
  final StorageRepository _storage;
  final AppcenterHttp _http;

  AuthenticationRepository({
    StorageRepository? storage,
    required AppcenterHttp http,
  })  : _storage = storage ?? StorageRepository(),
        _http = http {
    _restoreAuth().then(
      (value) =>
          _authSubscription = stream.skip(1).listen((t) => _persistAuth(t)),
    );
  }

  StreamSubscription? _authSubscription;
  final _authController = BehaviorSubject<AuthenticationState>.seeded(
    const AuthenticationState.unknown(),
  );

  Stream<AuthenticationState> get stream {
    return _authController.stream;
  }

  Future<void> login(
    String token, {
    AuthenticationAccess? access,
  }) async {
    _authController.add(
      const AuthenticationState.unauthenticated(),
    );
    final isValid = await _http.checkTokenValidity(token);
    if (isValid) {
      _authController.add(
        AuthenticationState.authenticated(
          token: token,
          access: access ?? AuthenticationAccess.readOnly,
        ),
      );
    }
  }

  void logout() {
    _authController.add(const AuthenticationState.unauthenticated());
  }

  Future<void> _persistAuth(AuthenticationState auth) async {
    await _storage.write(key: 'auth', value: jsonEncode(auth.toJson()));
  }

  Future<void> _restoreAuth() async {
    String? authValue;
    try {
      authValue = await _storage.read('auth');
    } catch (error) {
      debugPrint(error.toString());
    }
    if (authValue != null) {
      final auth = AuthenticationState.fromJson(jsonDecode(authValue));
      _authController.add(auth);
    } else {
      _authController.add(const AuthenticationState.unauthenticated());
    }
  }

  void dispose() {
    _authController.close();
    _authSubscription?.cancel();
  }
}
