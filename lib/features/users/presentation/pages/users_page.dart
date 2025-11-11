import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/utils/responsive_utils.dart';
import '../bloc/users_bloc.dart';
import '../widgets/user_list_item.dart';

class UsersPage extends StatelessWidget {
  final bool showAppBar;

  const UsersPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppResponsive.isDesktop(context);
    final isTablet = AppResponsive.isTablet(context);

    // Wrap everything in BlocProvider so it's available to all children
    return BlocProvider(
      create: (context) => di.getIt<UsersBloc>()..add(GetUsersRequested()),
      child: _UsersPageContent(
        showAppBar: showAppBar,
        isDesktop: isDesktop,
        isTablet: isTablet,
      ),
    );
  }
}

class _UsersPageContent extends StatelessWidget {
  final bool showAppBar;
  final bool isDesktop;
  final bool isTablet;

  const _UsersPageContent({
    required this.showAppBar,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state is UsersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UsersRefreshing) {
          return _buildUsersList(
            context,
            users: state.users,
            isLoading: true,
            isDesktop: isDesktop,
            isTablet: isTablet,
          );
        } else if (state is UsersLoaded) {
          if (state.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UsersBloc>().add(RefreshUsersRequested());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildUsersList(
              context,
              users: state.users,
              isLoading: false,
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
          );
        } else if (state is UsersError) {
          return Center(
            child: Padding(
              padding: AppResponsive.responsivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppResponsive.responsiveFontSize(
                      context,
                      mobile: 64,
                      tablet: 80,
                      desktop: 96,
                    ),
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: AppResponsive.responsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    ),
                  ),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      fontSize: AppResponsive.responsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: AppResponsive.responsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UsersBloc>().add(GetUsersRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );

    // If showAppBar is false, return just the content (for dashboard)
    if (!showAppBar) {
      return Column(
        children: [
          // Header with title and refresh button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<UsersBloc>().add(RefreshUsersRequested());
                  },
                ),
              ],
            ),
          ),
          // Content area - must be Expanded to prevent overflow
          Expanded(
            child: content,
          ),
        ],
      );
    }

    // Otherwise, return with Scaffold and AppBar
    return Scaffold(
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
      body: content,
    );
  }

  Widget _buildUsersList(
    BuildContext context, {
    required List users,
    required bool isLoading,
    required bool isDesktop,
    required bool isTablet,
  }) {
    // On desktop, use a grid layout
    if (isDesktop) {
      return Padding(
        padding: AppResponsive.responsivePadding(context),
        child: Stack(
          children: [
            GridView.builder(
              // Ensure GridView can scroll and has proper constraints
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppResponsive.responsiveGridColumns(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                ),
                crossAxisSpacing: AppResponsive.responsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
                mainAxisSpacing: AppResponsive.responsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
                // Aspect ratio - lower value gives more height to prevent overflow
                childAspectRatio: 1.75,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserListItem(user: users[index]);
              },
            ),
            if (isLoading)
              const Positioned(
                top: 16,
                right: 16,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      );
    }

    // On mobile and tablet, use list layout
    return Stack(
      children: [
        ListView.builder(
          padding: AppResponsive.responsivePadding(context),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: AppResponsive.responsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              child: UserListItem(user: users[index]),
            );
          },
        ),
        if (isLoading)
          const Positioned(
            top: 16,
            right: 16,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
