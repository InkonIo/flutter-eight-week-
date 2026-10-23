import 'package:flutter/material.dart';
import 'package:zadeight/main.dart';
import '../models/comment.dart';
import '../models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<List<Comment>> _comments;

  @override
  void initState() {
    super.initState();
    // репо берём через InheritedWidget или передаём — здесь просто через context
    final repo = PostRepositoryProvider.of(context);
    _comments = repo.getComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(title: Text('Пост #${post.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Автор: userId ${post.userId}'),
          const SizedBox(height: 12),
          Text(post.body),
          const Divider(height: 32),
          const Text('Комментарии', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<Comment>>(
            future: _comments,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Text('Ошибка: ${snap.error}');
              }
              final comments = snap.data!;
              return Column(
                children: comments
                    .map((c) => Card(
                          child: ListTile(
                            title: Text(c.name),
                            subtitle: Text(c.body),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}