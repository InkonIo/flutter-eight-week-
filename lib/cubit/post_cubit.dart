import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/post.dart';
import '../repository/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository repo;
  bool _loading = false;

  PostCubit(this.repo) : super(const PostState());

  // Загрузить первую страницу
  Future<void> load() async {
    emit(state.copy(status: Status.loading, posts: [], page: 1, hasMore: true, clearUser: true, search: ''));
    try {
      await for (final result in repo.getFirstPage()) {
        emit(state.copy(
          status: result.fromCache ? Status.cached : Status.success,
          posts: result.posts,
          fromCache: result.fromCache,
          page: result.fromCache ? 0 : 1,
          hasMore: !result.fromCache,
        ));
      }
    } catch (e) {
      emit(state.copy(status: Status.error, error: _msg(e)));
    }
  }

  // Подгрузить следующую страницу
  Future<void> loadMore() async {
    if (_loading || !state.hasMore || state.loadingMore) return;
    _loading = true;
    emit(state.copy(loadingMore: true));
    try {
      final next = state.page + 1;
      final more = await repo.getPage(next);
      emit(state.copy(
        status: Status.success,
        posts: [...state.posts, ...more],
        page: next,
        hasMore: more.length == 10,
        loadingMore: false,
      ));
    } catch (e) {
      emit(state.copy(loadingMore: false, error: _msg(e)));
    } finally {
      _loading = false;
    }
  }

  // Фильтр по пользователю
  Future<void> filterUser(int? userId) async {
    if (userId == null) { load(); return; }
    emit(state.copy(status: Status.loading, posts: [], userId: userId));
    try {
      final posts = await repo.getUserPosts(userId);
      emit(state.copy(status: Status.success, posts: posts, hasMore: false));
    } catch (e) {
      emit(state.copy(status: Status.error, error: _msg(e)));
    }
  }

  // Поиск (локальный)
  void search(String q) => emit(state.copy(search: q));

  // Сброс
  void reset() => load();

  // Загрузить список пользователей
  Future<void> loadUsers() async {
    try {
      final users = await repo.getUsers();
      emit(state.copy(users: users));
    } catch (_) {}
  }

  // Добавить локальный пост в начало списка
  void addLocal(Post post) {
    emit(state.copy(posts: [post, ...state.posts]));
  }

  String _msg(Object e) => e.toString().replaceAll('Exception: ', '');
}