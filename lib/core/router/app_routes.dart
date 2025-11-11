/// App route constants
/// Centralized route paths and names for type-safe navigation
class AppRoutes {
  // Route paths
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String posts = '/posts';

  // Route names (for named navigation)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String dashboardName = 'dashboard';
  static const String usersName = 'users';
  static const String postDetailName = 'post-detail';

  // Helper method to build post detail path
  static String postDetail(int id) => '$posts/$id';
}
