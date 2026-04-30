import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/post.dart';

/// Base URL for DummyJSON public API.
/// Tested accessible from China (as of 2026-04-10).
const _baseUrl = 'https://dummyjson.com';

/// API service for fetching data from DummyJSON.
///
/// Uses plain http calls — the actual caching, retry, and loading state
/// is handled by fquery in the calling layer.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<User>> getUsers() async {
    final res = await _client.get(Uri.parse('$_baseUrl/users?limit=20'));
    if (res.statusCode != 200) throw _HttpException(res.statusCode);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['users'] as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User> getUser(int id) async {
    final res = await _client.get(Uri.parse('$_baseUrl/users/$id'));
    if (res.statusCode != 200) throw _HttpException(res.statusCode);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<Post>> getPosts() async {
    final res = await _client.get(Uri.parse('$_baseUrl/posts?limit=50'));
    if (res.statusCode != 200) throw _HttpException(res.statusCode);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['posts'] as List;
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final res =
        await _client.get(Uri.parse('$_baseUrl/posts/user/$userId?limit=10'));
    if (res.statusCode != 200) throw _HttpException(res.statusCode);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['posts'] as List;
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Post> getPost(int id) async {
    final res = await _client.get(Uri.parse('$_baseUrl/posts/$id'));
    if (res.statusCode != 200) throw _HttpException(res.statusCode);
    return Post.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Post> createPost(Map<String, String> data) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/posts/add'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw _HttpException(res.statusCode);
    }
    return Post.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

class _HttpException implements Exception {
  final int statusCode;
  _HttpException(this.statusCode);

  @override
  String toString() => 'HTTP error: $statusCode';
}
