// filepath: /Users/sandy/Flutter New Projects/agora_call/lib/service/local_storage.dart
import 'package:agora_call/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';


class HiveLocalStorage {

  HiveLocalStorage._privateConstructor();
  static final HiveLocalStorage instance = HiveLocalStorage._privateConstructor();
  
  final Box box = Hive.box('localStorageBox');

  Future<void> saveData(String key, List<UserModel> value) async {
    await box.put(key, value);
  }

  List<UserModel>? getData(String key) {
    return box.get(key);
  }

  Future<void> deleteData(String key) async {
    await box.delete(key);
  }

  Future<void> clearAllData() async {
    await box.clear();
  }
}