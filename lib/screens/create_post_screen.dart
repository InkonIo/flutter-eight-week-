import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zadeight/main.dart';
import '../cubit/post_cubit.dart';
import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _userId = 1;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = PostRepositoryProvider.of(context);
      final post = await repo.createPost(_title.text, _body.text, _userId);
      // Помечаем как локальный и добавляем в список
      final local = Post(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
        isLocal: true,
      );
      if (mounted) {
        context.read<PostCubit>().addLocal(local);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пост создан: id=${post.id}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать пост')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Заголовок'),
                validator: (v) {
                  if (v == null || v.length < 5) return 'Минимум 5 символов';
                  if (v.length > 100) return 'Максимум 100 символов';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                decoration: const InputDecoration(labelText: 'Текст поста'),
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.length < 10) return 'Минимум 10 символов';
                  if (v.length > 1000) return 'Максимум 1000 символов';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _userId,
                decoration: const InputDecoration(labelText: 'Пользователь'),
                items: List.generate(10, (i) => i + 1)
                    .map((id) => DropdownMenuItem(value: id, child: Text('User $id')))
                    .toList(),
                onChanged: (v) => setState(() => _userId = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Отправить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}