import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../posts/domain/entities/post_entity.dart';
import '../bloc/comments_bloc.dart';
import '../widgets/comment_list_item.dart';
import '../widgets/add_comment_form.dart';

class PostDetailPage extends StatelessWidget {
  final PostEntity post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.getIt<CommentsBloc>()..add(GetCommentsByPostIdRequested(post.id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Post Details')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User ID: ${post.userId}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Text(post.body, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const Divider(),
              // Add Comment Form
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AddCommentForm(postId: post.id),
              ),
              const Divider(),
              // Comments section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.comment),
                    const SizedBox(width: 8),
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  if (state is CommentsLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is CommentsLoaded ||
                      state is CommentsCreating) {
                    final comments = state is CommentsLoaded
                        ? state.comments
                        : (state as CommentsCreating).comments;

                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: state is CommentsCreating
                              ? const CircularProgressIndicator()
                              : const Text('No comments found'),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return CommentListItem(comment: comments[index]);
                          },
                        ),
                        if (state is CommentsCreating)
                          const Positioned(
                            top: 16,
                            right: 16,
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    );
                  } else if (state is CommentsError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text('Error: ${state.message}'),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
