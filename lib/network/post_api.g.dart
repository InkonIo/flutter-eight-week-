// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'post_api.dart';

class _PostApi implements PostApi {
  _PostApi(this._dio, {this.baseUrl});
  final Dio _dio;
  String? baseUrl;

  @override
  Future<List<Post>> getPosts(int page, int limit) async {
    final result = await _dio.fetch<List>(_setStreamType(
      Options(method: 'GET').compose(
        _dio.options, '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return result.data!.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Post> getPostById(int id) async {
    final result = await _dio.fetch<Map<String, dynamic>>(_setStreamType(
      Options(method: 'GET').compose(
        _dio.options, '/posts/$id',
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return Post.fromJson(result.data!);
  }

  @override
  Future<List<Post>> getPostsByUser(int userId) async {
    final result = await _dio.fetch<List>(_setStreamType(
      Options(method: 'GET').compose(
        _dio.options, '/posts',
        queryParameters: {'userId': userId},
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return result.data!.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Comment>> getComments(int postId) async {
    final result = await _dio.fetch<List>(_setStreamType(
      Options(method: 'GET').compose(
        _dio.options, '/posts/$postId/comments',
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return result.data!.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Post> createPost(Map<String, dynamic> body) async {
    final result = await _dio.fetch<Map<String, dynamic>>(_setStreamType(
      Options(method: 'POST').compose(
        _dio.options, '/posts',
        data: body,
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return Post.fromJson(result.data!);
  }

  @override
  Future<List<User>> getUsers() async {
    final result = await _dio.fetch<List>(_setStreamType(
      Options(method: 'GET').compose(
        _dio.options, '/users',
      ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
    ));
    return result.data!.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  RequestOptions _setStreamType<T>(RequestOptions o) {
    if (T != dynamic) o.responseType = ResponseType.json;
    return o;
  }
}