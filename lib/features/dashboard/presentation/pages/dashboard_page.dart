import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../posts/presentation/pages/posts_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../users/presentation/pages/users_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDesktop = AppResponsive.isDesktop(context);
    final isCompact = AppResponsive.isCompactLayout(context);

    // Show sidebar only on desktop
    // Mobile and tablet always use tabs
    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations?.dashboard ?? 'Dashboard')),
        body: Row(
          children: [
            // Sidebar navigation
            Container(
              width: 200,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.article,
                      color: _selectedIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(localizations?.posts ?? 'Posts'),
                    selected: _selectedIndex == 0,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: _selectedIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(localizations?.users ?? 'Users'),
                    selected: _selectedIndex == 1,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: _selectedIndex == 2
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(localizations?.settings ?? 'Settings'),
                    selected: _selectedIndex == 2,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Content area - show selected page
            Expanded(child: _getPageForIndex(_selectedIndex)),
          ],
        ),
      );
    }

    // Use tabs for mobile and tablet
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.dashboard ?? 'Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.article),
                text: isCompact ? null : (localizations?.posts ?? 'Posts'),
                iconMargin: isCompact
                    ? const EdgeInsets.only(bottom: 8)
                    : const EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: const Icon(Icons.people),
                text: isCompact ? null : (localizations?.users ?? 'Users'),
                iconMargin: isCompact
                    ? const EdgeInsets.only(bottom: 8)
                    : const EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: isCompact
                    ? null
                    : (localizations?.settings ?? 'Settings'),
                iconMargin: isCompact
                    ? const EdgeInsets.only(bottom: 8)
                    : const EdgeInsets.only(bottom: 4),
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

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return const PostsPage();
      case 1:
        return const UsersPage(showAppBar: false);
      case 2:
        return const SettingsPage();
      default:
        return const PostsPage();
    }
  }
}
