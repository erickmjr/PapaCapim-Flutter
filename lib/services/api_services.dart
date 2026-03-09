import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ApiService {
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? sessionToken,
  }) async {
    final baseUrl = Uri.parse("${AppConfig.baseUrl}$endpoint");
    final Uri url = queryParameters == null || queryParameters.isEmpty
        ? baseUrl
        : baseUrl.replace(
            queryParameters: {
              ...baseUrl.queryParameters,
              ...queryParameters,
            },
          );

    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (sessionToken != null && sessionToken.isNotEmpty)
          "x-session-token": sessionToken,
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
