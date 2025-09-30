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
    final data = box.get(key);
    if (data == null) return null;

    if (data is List<UserModel>) return data;

    if (data is List) {
      return data.map((e) {
        if (e is UserModel) return e;
        if (e is Map) return UserModel.fromMap(Map<String, dynamic>.from(e));
        return null;
      }).whereType<UserModel>().toList();
    }

    return null;
  }

  Future<void> deleteData(String key) async {
    await box.delete(key);
  }

  Future<void> clearAllData() async {
    await box.clear();
  }
}