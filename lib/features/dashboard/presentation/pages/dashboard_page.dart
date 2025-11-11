import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../posts/presentation/pages/posts_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../users/presentation/pages/users_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.dashboard ?? 'Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.article),
                text: localizations?.posts ?? 'Posts',
              ),
              Tab(
                icon: const Icon(Icons.people),
                text: localizations?.users ?? 'Users',
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: localizations?.settings ?? 'Settings',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [PostsPage(), UsersPage(), SettingsPage()],
        ),
      ),
    );
  }
}
