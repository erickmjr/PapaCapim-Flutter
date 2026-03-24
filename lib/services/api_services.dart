import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class ApiService {
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? sessionToken,
  }) async {
    final Uri url = _buildUri(endpoint, queryParameters: queryParameters);
    return http.get(url, headers: _headers(sessionToken: sessionToken));
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) async {
    final Uri url = _buildUri(endpoint);
    return http.post(
      url,
      headers: _headers(sessionToken: sessionToken),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) async {
    final Uri url = _buildUri(endpoint);
    return http.patch(
      url,
      headers: _headers(sessionToken: sessionToken),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) async {
    final Uri url = _buildUri(endpoint);
    return http.delete(
      url,
      headers: _headers(sessionToken: sessionToken),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> follow(
    String userLogin,
    String sessionToken,
  ) {
    return post(
      '/users/$userLogin/followers',
      sessionToken: sessionToken,
    );
  }

  static Future<http.Response> unfollow(
    String userLogin,
    String sessionToken,
    int followerId,
  ) {
    return delete(
      '/users/$userLogin/followers/$followerId',
      sessionToken: sessionToken,
    );
  }

  static Future<http.Response> createPost(
    String message,
    String sessionToken,
  ) {
    return post(
      '/posts',
      sessionToken: sessionToken,
      body: {
        'post': {
          'message': message,
        },
      },
    );
  }

  static Future<http.Response> replyToPost(
    int postId,
    String message,
    String sessionToken,
  ) {
    return post(
      '/posts/$postId/replies',
      sessionToken: sessionToken,
      body: {
        'reply': {
          'message': message,
        },
      },
    );
  }

  static Future<http.Response> deletePost(
    int postId,
    String sessionToken,
  ) {
    return delete('/posts/$postId', sessionToken: sessionToken);
  }

  static Future<http.Response> likePost(
    int postId,
    String sessionToken,
  ) {
    return post('/posts/$postId/likes', sessionToken: sessionToken);
  }

  static Future<http.Response> unlikePost(
    int postId,
    int likeId,
    String sessionToken,
  ) {
    return delete('/posts/$postId/likes/$likeId', sessionToken: sessionToken);
  }

  static Future<http.Response> getUser(String login, String sessionToken) {
    return get('/users/$login', sessionToken: sessionToken);
  }

  static Future<http.Response> listUsers({
    String? search,
    int? page,
    required String sessionToken,
  }) {
    return get(
      '/users',
      sessionToken: sessionToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
  }

  static Future<http.Response> updateUser(
    String userLogin,
    Map<String, dynamic> user,
    String sessionToken,
  ) {
    return patch(
      '/users/$userLogin',
      sessionToken: sessionToken,
      body: {
        'user': user,
      },
    );
  }

  static Future<http.Response> deleteUser(
    String userLogin,
    String sessionToken,
  ) {
    return delete('/users/$userLogin', sessionToken: sessionToken);
  }

  static Future<http.Response> listFollowers(
    String login,
    String sessionToken,
  ) {
    return get('/users/$login/followers', sessionToken: sessionToken);
  }

  static Future<http.Response> listPosts({
    String? search,
    bool feedOnly = false,
    int? page,
    required String sessionToken,
  }) {
    return get(
      '/posts',
      sessionToken: sessionToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (feedOnly) 'feed': '1',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
  }

  static Future<http.Response> listUserPosts(
    String login,
    String sessionToken, {
    int? page,
  }) {
    return get(
      '/users/$login/posts',
      sessionToken: sessionToken,
      queryParameters: {
        if (page != null) 'page': '$page',
      },
    );
  }

  static Future<http.Response> listReplies(
    int postId,
    String sessionToken, {
    int? page,
  }) {
    return get(
      '/posts/$postId/replies',
      sessionToken: sessionToken,
      queryParameters: {
        if (page != null) 'page': '$page',
      },
    );
  }

  static Future<http.Response> getPost(
    int postId,
    String sessionToken,
  ) {
    return get('/posts/$postId', sessionToken: sessionToken);
  }

  static Future<http.Response> listLikes(
    int postId,
    String sessionToken,
  ) {
    return get('/posts/$postId/likes', sessionToken: sessionToken);
  }

  static Uri _buildUri(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    final Uri baseUrl = Uri.parse('${AppConfig.baseUrl}$endpoint');
    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUrl;
    }
    return baseUrl.replace(
      queryParameters: {
        ...baseUrl.queryParameters,
        ...queryParameters,
      },
    );
  }

  static Map<String, String> _headers({String? sessionToken}) {
    return {
      'Content-Type': 'application/json',
      if (sessionToken != null && sessionToken.isNotEmpty)
        'x-session-token': sessionToken,
    };
  }
}
