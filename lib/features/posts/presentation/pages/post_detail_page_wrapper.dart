import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../bloc/post_detail_bloc.dart';
import '../../../comments/presentation/pages/post_detail_page.dart';

class PostDetailPageWrapper extends StatelessWidget {
  final int postId;

  const PostDetailPageWrapper({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<PostDetailBloc>()
        ..add(GetPostByIdRequested(postId)),
      child: BlocBuilder<PostDetailBloc, PostDetailState>(
        builder: (context, state) {
          if (state is PostDetailLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Post Details')),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is PostDetailLoaded) {
            return PostDetailPage(post: state.post);
          } else if (state is PostDetailError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Post Details')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PostDetailBloc>().add(GetPostByIdRequested(postId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Post Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
