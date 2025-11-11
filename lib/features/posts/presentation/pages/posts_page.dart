import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_routes.dart';
import '../bloc/posts_bloc.dart';
import '../widgets/post_list_item.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<PostsBloc>()..add(GetPostsRequested()),
      child: Scaffold(
        body: BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is PostsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostsRefreshing) {
              return Stack(
                children: [
                  ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      return PostListItem(
                        post: state.posts[index],
                        onTap: () {
                          context.push(
                            AppRoutes.postDetail(state.posts[index].id),
                          );
                        },
                      );
                    },
                  ),
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            } else if (state is PostsLoaded) {
              if (state.posts.isEmpty) {
                return const Center(child: Text('No posts found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostsBloc>().add(RefreshPostsRequested());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    return PostListItem(
                      post: state.posts[index],
                      onTap: () {
                        context.push('/posts/${state.posts[index].id}');
                      },
                    );
                  },
                ),
              );
            } else if (state is PostsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PostsBloc>().add(GetPostsRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
