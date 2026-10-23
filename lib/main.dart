import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubit/post_cubit.dart';
import 'network/dio_client.dart';
import 'network/post_api.dart';
import 'repository/post_cache.dart';
import 'repository/post_repository.dart';
import 'screens/posts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final api = PostApi(DioClient.instance);
  final cache = PostCache(prefs);
  final repo = PostRepository(api, cache);

  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final PostRepository repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return PostRepositoryProvider(
      repo: repo,
      child: BlocProvider(
        create: (_) => PostCubit(repo),
        child: const MaterialApp(
          title: 'Post Explorer',
          home: PostsScreen(),
        ),
      ),
    );
  }
}

// Простой InheritedWidget чтобы передавать репозиторий в экраны
class PostRepositoryProvider extends InheritedWidget {
  final PostRepository repo;

  const PostRepositoryProvider({
    super.key,
    required this.repo,
    required super.child,
  });

  static PostRepository of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PostRepositoryProvider>()!.repo;
  }

  @override
  bool updateShouldNotify(_) => false;
}