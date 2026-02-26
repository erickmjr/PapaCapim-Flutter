import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ApiService {

  static Future<http.Response> get(String endpoint) async {
    final Uri url = Uri.parse("${AppConfig.baseUrl}$endpoint");

    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final Uri url = Uri.parse("${AppConfig.baseUrl}$endpoint");

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
