import 'package:dio/dio.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../network/post_api.dart';
import 'post_cache.dart';

class PostRepository {
  final PostApi api;
  final PostCache cache;

  PostRepository(this.api, this.cache);

  // Получить первую страницу. Сначала отдаём кэш, потом свежие данные
  Stream<({List<Post> posts, bool fromCache})> getFirstPage() async* {
    final cached = cache.load();
    if (cached != null) {
      yield (posts: cached, fromCache: true);
    }
    try {
      final fresh = await api.getPosts(1, 10);
      await cache.save(fresh);
      yield (posts: fresh, fromCache: false);
    } on DioException catch (e) {
      if (cached == null) rethrow;
      // есть кэш — молча игнорируем ошибку сети
    }
  }

  // Следующие страницы (пагинация)
  Future<List<Post>> getPage(int page) => api.getPosts(page, 10);

  // Пост по id
  Future<Post> getPost(int id) => api.getPostById(id);

  // Посты пользователя
  Future<List<Post>> getUserPosts(int userId) => api.getPostsByUser(userId);

  // Комментарии
  Future<List<Comment>> getComments(int postId) => api.getComments(postId);

  // Создать пост
  Future<Post> createPost(String title, String body, int userId) =>
      api.createPost({'title': title, 'body': body, 'userId': userId});

  // Список пользователей
  Future<List<User>> getUsers() => api.getUsers();
}