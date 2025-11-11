import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../bloc/users_bloc.dart';
import '../widgets/user_list_item.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<UsersBloc>()..add(GetUsersRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<UsersBloc>().add(RefreshUsersRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersRefreshing) {
            return Stack(
              children: [
                ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    return UserListItem(user: state.users[index]);
                  },
                ),
                const Positioned(
                  top: 16,
                  right: 16,
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          } else if (state is UsersLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<UsersBloc>().add(RefreshUsersRequested());
                // Wait a bit for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  return UserListItem(user: state.users[index]);
                },
              ),
            );
          } else if (state is UsersError) {
            return Center(
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
                      context.read<UsersBloc>().add(GetUsersRequested());
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

