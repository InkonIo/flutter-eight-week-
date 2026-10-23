import 'package:equatable/equatable.dart';
import '../models/post.dart';
import '../models/user.dart';

enum Status { initial, loading, success, error, cached }

class PostState extends Equatable {
  final Status status;
  final List<Post> posts;
  final List<User> users;
  final String error;
  final bool fromCache;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String search;
  final int? userId;

  const PostState({
    this.status = Status.initial,
    this.posts = const [],
    this.users = const [],
    this.error = '',
    this.fromCache = false,
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.search = '',
    this.userId,
  });

  PostState copy({
    Status? status,
    List<Post>? posts,
    List<User>? users,
    String? error,
    bool? fromCache,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? search,
    int? userId,
    bool clearUser = false,
  }) =>
      PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        users: users ?? this.users,
        error: error ?? this.error,
        fromCache: fromCache ?? this.fromCache,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        search: search ?? this.search,
        userId: clearUser ? null : userId ?? this.userId,
      );

  // Посты с учётом поиска
  List<Post> get filtered {
    var list = posts;
    if (search.isNotEmpty) {
      list = list.where((p) => p.title.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return list;
  }

  @override
  List<Object?> get props => [status, posts, users, error, fromCache, page, hasMore, loadingMore, search, userId];
}