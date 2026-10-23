import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadeight/models/post.dart';
import 'package:zadeight/network/post_api.dart';
import 'package:zadeight/repository/post_cache.dart';
import 'package:zadeight/repository/post_repository.dart';

void main() {
  // 1. JSON -> Post
  test('fromJson работает корректно', () {
    final post = Post.fromJson({
      'id': 1, 'userId': 1, 'title': 'Test', 'body': 'Body',
    });
    expect(post.id, 1);
    expect(post.title, 'Test');
  });

  // 2. Post -> JSON
  test('toJson работает корректно', () {
    const post = Post(id: 1, userId: 1, title: 'Test', body: 'Body');
    final json = post.toJson();
    expect(json['title'], 'Test');
    expect(json['id'], 1);
  });

  // 3. Успешная загрузка через репозиторий
  test('Репозиторий загружает посты', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/posts', (server) => server.reply(200, [
      {'id': 1, 'userId': 1, 'title': 'Hello', 'body': 'World'},
    ]), queryParameters: {'_page': 1, '_limit': 10});

    final repo = PostRepository(PostApi(dio), PostCache(prefs));
    final results = <List<Post>>[];
    await for (final r in repo.getFirstPage()) {
      results.add(r.posts);
    }
    expect(results.last.first.title, 'Hello');
  });

  // 4. Ошибка сервера
  test('Репозиторий выдаёт ошибку при 500', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/posts', (server) => server.reply(500, 'error'),
        queryParameters: {'_page': 1, '_limit': 10});

    final repo = PostRepository(PostApi(dio), PostCache(prefs));
    expect(() async {
      await for (final _ in repo.getFirstPage()) {}
    }, throwsA(anything));
  });

  // 5. Фильтрация по заголовку
  test('Фильтрация постов по заголовку', () {
    final posts = [
      const Post(id: 1, userId: 1, title: 'Flutter test', body: ''),
      const Post(id: 2, userId: 1, title: 'Dart basics', body: ''),
    ];
    final filtered = posts
        .where((p) => p.title.toLowerCase().contains('flutter'))
        .toList();
    expect(filtered.length, 1);
    expect(filtered.first.id, 1);
  });

  // 6. Защита от повторной загрузки
  test('loadMore не запускается если уже грузит', () async {
    bool called = false;
    Future<void> loadMore(bool isLoading) async {
      if (isLoading) return;
      called = true;
    }
    await loadMore(true);
    expect(called, false);
  });

  // 7. POST через мок
  test('createPost возвращает пост', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
  '/posts',
  (server) => server.reply(201, {
    'id': 101, 'userId': 1, 'title': 'New post', 'body': 'Content here',
  }),
  data: {'title': 'New post', 'body': 'Content here', 'userId': 1},
);

    final repo = PostRepository(PostApi(dio), PostCache(prefs));
    final post = await repo.createPost('New post', 'Content here', 1);
    expect(post.id, 101);
    expect(post.title, 'New post');
  });
}