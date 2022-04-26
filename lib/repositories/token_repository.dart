import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

class TokenRepository {
  final FlutterSecureStorage _storage;

  TokenRepository({FlutterSecureStorage? storage})
      : _storage =
            storage ?? const FlutterSecureStorage(mOptions: MacOsOptions()) {
    _restoreToken().then(
      (value) =>
          _tokenSubscription = token.skip(1).listen((t) => _persistToken(t)),
    );
  }

  late final StreamSubscription<String?>? _tokenSubscription;
  final _tokenController = BehaviorSubject<String?>();

  Stream<String?> get token {
    return _tokenController.stream;
  }

  Future<void> setToken(String token) async {
    _tokenController.add(token);
  }

  void clearToken() {
    _tokenController.add(null);
  }

  Future<void> _persistToken(String? token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<void> _restoreToken() async {
    String? tokenValue;
    try {
      tokenValue = await _storage.read(key: 'token');
    } catch (error) {
      print(error);
    }
    if (tokenValue != null) {
      _tokenController.add(tokenValue);
    } else {
      _tokenController.add(null);
    }
  }

  void dispose() {
    _tokenController.close();
    _tokenSubscription?.cancel();
  }
}
