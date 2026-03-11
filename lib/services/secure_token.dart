import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = "user";

  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  static Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _userKey);

    if (userJson == null) return null;

    final Map<String, dynamic> data = jsonDecode(userJson);

    return UserModel.fromJson(data);
  }

  static Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }

  static Future<String?> getToken() async {
    final user = await getUser();
    return user?.token;
  }
}