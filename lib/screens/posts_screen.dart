import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PostCubit>().load();
    context.read<PostCubit>().loadUsers();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<PostCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          return Column(
            children: [
              // Поиск
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Поиск по заголовку (локальный)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              context.read<PostCubit>().search('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: context.read<PostCubit>().search,
                ),
              ),

              // Фильтр по пользователю
              if (state.users.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: const Text('Все'),
                          selected: state.userId == null,
                          onSelected: (_) => context.read<PostCubit>().filterUser(null),
                        ),
                      ),
                      ...state.users.map((u) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(u.name),
                              selected: state.userId == u.id,
                              onSelected: (_) => context.read<PostCubit>().filterUser(u.id),
                            ),
                          )),
                    ],
                  ),
                ),

              // Баннер кэша
              if (state.fromCache)
                Container(
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.all(6),
                  child: const Row(
                    children: [
                      Icon(Icons.offline_bolt, size: 16),
                      SizedBox(width: 6),
                      Text('Данные из кэша'),
                    ],
                  ),
                ),

              // Контент
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(PostState state) {
    if (state.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == Status.error && state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: context.read<PostCubit>().load,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final posts = state.filtered;

    if (posts.isEmpty) {
      return const Center(child: Text('Нет постов'));
    }

    return RefreshIndicator(
      onRefresh: context.read<PostCubit>().load,
      child: ListView.builder(
        controller: _scroll,
        itemCount: posts.length + (state.loadingMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = posts[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${post.userId}')),
            title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: post.isLocal
                ? const Text('✏️ создан локально', style: TextStyle(color: Colors.orange))
                : Text('Пост #${post.id}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
            ),
          );
        },
      ),
    );
  }
}