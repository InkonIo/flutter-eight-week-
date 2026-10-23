import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class PostCache {
  static const _key = 'cached_posts';
  final SharedPreferences prefs;

  PostCache(this.prefs);

  // Сохранить посты
  Future<void> save(List<Post> posts) async {
    final data = jsonEncode(posts.map((p) => p.toJson()).toList());
    await prefs.setString(_key, data);
  }

  // Загрузить посты из кэша
  List<Post>? load() {
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}