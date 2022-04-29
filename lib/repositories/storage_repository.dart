import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  StorageRepository() {
    // Can't use secure storage on mac os if the app not signed, which will required a developer program account
    _useSecureStorage = !Platform.isMacOS;
  }

  late final bool _useSecureStorage;

  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
  final FlutterSecureStorage _flutterSecureStorage =
      const FlutterSecureStorage();

  Future<String?> read(String key) async {
    if (_useSecureStorage) {
      return _flutterSecureStorage.read(key: key);
    }
    return sharedPreferences.then((prefs) => prefs.getString(key));
  }

  Future<void> write({required String key, String? value}) async {
    if (_useSecureStorage) {
      return _flutterSecureStorage.write(key: key, value: value);
    }
    return sharedPreferences.then((prefs) => prefs.setString(key, value ?? ''));
  }

  Future<void> remove(String key) async {
    if (_useSecureStorage) {
      return _flutterSecureStorage.delete(key: key);
    }
    return sharedPreferences.then((prefs) => prefs.remove(key));
  }
}
