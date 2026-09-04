import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);
  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async =>
      LocalStorageService(await SharedPreferences.getInstance());

  Future<bool> setBool(String key, {required bool value}) =>
      _preferences.setBool(key, value);
  bool? getBool(String key) => _preferences.getBool(key);
  Future<bool> remove(String key) => _preferences.remove(key);
}
