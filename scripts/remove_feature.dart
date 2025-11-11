#!/usr/bin/env dart

import 'dart:io';

/// Script to remove a feature from the project
/// Usage: dart run scripts/remove_feature.dart <feature_name>
/// Example: dart run scripts/remove_feature.dart products

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Error: Feature name is required');
    print('Usage: dart run scripts/remove_feature.dart <feature_name>');
    print('Example: dart run scripts/remove_feature.dart products');
    exit(1);
  }

  final featureName = args[0].toLowerCase();
  final featureRemover = FeatureRemover(featureName);
  featureRemover.remove();
}

class FeatureRemover {
  final String featureName;
  final String featureNamePascal;
  final String featureNameCamel;
  final String featureNamePlural;
  final String featureNamePluralPascal;
  final String featureNamePluralCamel;

  FeatureRemover(this.featureName)
    : featureNamePascal = _toPascalCase(featureName),
      featureNameCamel = _toCamelCase(featureName),
      featureNamePlural = _pluralize(featureName),
      featureNamePluralPascal = _toPascalCase(_pluralize(featureName)),
      featureNamePluralCamel = _toCamelCase(_pluralize(featureName));

  static String _toPascalCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join();
  }

  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  static String _pluralize(String word) {
    if (word.endsWith('y')) {
      return word.substring(0, word.length - 1) + 'ies';
    } else if (word.endsWith('s') ||
        word.endsWith('x') ||
        word.endsWith('z') ||
        word.endsWith('ch') ||
        word.endsWith('sh')) {
      return word + 'es';
    } else {
      return word + 's';
    }
  }

  void remove() {
    print('🗑️  Removing feature: $featureNamePascal\n');

    try {
      // Check if feature directory exists
      final featureDir = Directory('lib/features/$featureName');
      if (!featureDir.existsSync()) {
        print('❌ Error: Feature "$featureName" does not exist');
        print('   Directory not found: ${featureDir.path}');
        exit(1);
      }

      // Confirm removal
      print('⚠️  This will permanently delete:');
      print('   - lib/features/$featureName/');
      print('   - All imports and registrations in DI container');
      print('   - All routes in router');
      print('   - All route constants');
      print('');
      print('Are you sure you want to continue? (yes/no): ');

      final confirmation = stdin.readLineSync()?.toLowerCase().trim();
      if (confirmation != 'yes' && confirmation != 'y') {
        print('❌ Removal cancelled');
        exit(0);
      }

      _removeFromDependencyInjection();
      _removeFromRouter();
      _removeFromRoutes();
      _removeFeatureDirectory();

      print('\n✅ Feature "$featureNamePascal" removed successfully!');
      print('\n📝 Next steps:');
      print('1. Run: flutter pub get');
      print(
        '2. Run: flutter pub run build_runner build --delete-conflicting-outputs',
      );
      print('3. Verify the app still compiles and runs correctly');
    } catch (e) {
      print('❌ Error removing feature: $e');
      exit(1);
    }
  }

  void _removeFromDependencyInjection() {
    print('🔌 Removing from dependency injection...');

    final diFile = File('lib/core/di/injection_container.dart');
    var content = diFile.readAsStringSync();

    // Remove imports - remove each import line
    final importLines = [
      '// ${featureNamePascal} Feature',
      "import '../../features/$featureName/data/datasources/${featureName}_local_data_source.dart';",
      "import '../../features/$featureName/data/datasources/${featureName}_remote_data_source.dart';",
      "import '../../features/$featureName/data/repositories/${featureName}_repository_impl.dart';",
      "import '../../features/$featureName/domain/repositories/${featureName}_repository.dart';",
      "import '../../features/$featureName/domain/usecases/get_${featureNamePlural}_usecase.dart';",
      "import '../../features/$featureName/domain/usecases/get_${featureName}_by_id_usecase.dart';",
      "import '../../features/$featureName/presentation/bloc/${featureName}_bloc.dart';",
    ];

    for (final line in importLines) {
      // Remove the line with its newline
      content = content.replaceAll(RegExp('${RegExp.escape(line)}\n?'), '');
    }

    // Remove registrations block
    final registrationStart =
        '  // ========== ${featureNamePascal} Feature ==========';
    final registrationEnd = '  // ========== Network Services ==========';

    if (content.contains(registrationStart) &&
        content.contains(registrationEnd)) {
      final lines = content.split('\n');
      final newLines = <String>[];
      bool skipBlock = false;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];

        if (line.contains(registrationStart)) {
          skipBlock = true;
          continue;
        }

        if (skipBlock && line.contains(registrationEnd)) {
          skipBlock = false;
          // Keep the Network Services line
          newLines.add(line);
          continue;
        }

        if (!skipBlock) {
          newLines.add(line);
        }
      }

      content = newLines.join('\n');
    }

    // Clean up extra blank lines (more than 2 consecutive)
    content = content.replaceAll(RegExp(r'\n\n\n+'), '\n\n');

    diFile.writeAsStringSync(content);
  }

  void _removeFromRouter() {
    print('🛣️  Removing from router...');

    final routerFile = File('lib/core/router/app_router.dart');
    var content = routerFile.readAsStringSync();

    // Remove import
    final importPattern =
        "import '../../features/$featureName/presentation/pages/${featureNamePlural}_page.dart';";
    content = content.replaceAll(
      RegExp('${RegExp.escape(importPattern)}\n?'),
      '',
    );

    // Remove route using line-by-line approach
    final lines = content.split('\n');
    final newLines = <String>[];
    bool skipRoute = false;
    int parenCount = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();

      // Check if this line starts the route we want to remove
      if (!skipRoute &&
          (line.contains('path: AppRoutes.$featureNamePluralCamel') ||
              line.contains('path: AppRoutes.$featureNameCamel'))) {
        skipRoute = true;
        parenCount = 0;
        // Count opening parentheses in this line
        parenCount += '('.allMatches(line).length;
        parenCount -= ')'.allMatches(line).length;
        continue;
      }

      if (skipRoute) {
        // Count parentheses to track nested structures
        parenCount += '('.allMatches(line).length;
        parenCount -= ')'.allMatches(line).length;

        // Check if route block ended (closing parenthesis and comma, or just closing parenthesis)
        // Routes typically end with "),"
        if (parenCount <= 0 &&
            (trimmedLine.endsWith('),') || trimmedLine == ')')) {
          skipRoute = false;
          // Don't add this line (the closing ),)
          continue;
        }
        // Skip all lines in the route block
        continue;
      }

      newLines.add(line);
    }

    content = newLines.join('\n');

    // Clean up empty GoRoute blocks that might have been left behind
    // Handle both single-line and multi-line empty GoRoute blocks
    content = content.replaceAll(
      RegExp(r'^\s*GoRoute\(\s*\),?\s*$', multiLine: true),
      '',
    );
    // Also handle GoRoute with just whitespace/newlines
    content = content.replaceAll(
      RegExp(r'^\s*GoRoute\(\s*\n\s*\),?\s*$', multiLine: true),
      '',
    );

    // Clean up extra blank lines
    content = content.replaceAll(RegExp(r'\n\n\n+'), '\n\n');

    routerFile.writeAsStringSync(content);
  }

  void _removeFromRoutes() {
    print('📍 Removing from route constants...');

    final routesFile = File('lib/core/router/app_routes.dart');
    var content = routesFile.readAsStringSync();

    // Remove route constants line by line
    final lines = content.split('\n');
    final newLines = <String>[];

    for (final line in lines) {
      // Skip lines that match our feature's route constants
      // Check for route path (e.g., "static const String todos = '/todos';")
      if (line.contains('static const String $featureNamePluralCamel =') ||
          line.contains('static const String $featureNameCamel =')) {
        continue;
      }
      // Check for route name (e.g., "static const String todosName = 'todos';")
      final routeNamePattern = '${featureNamePluralCamel}Name';
      final routeNamePattern2 = '${featureNameCamel}Name';
      if (line.contains('static const String $routeNamePattern =') ||
          line.contains('static const String $routeNamePattern2 =')) {
        continue;
      }
      newLines.add(line);
    }

    content = newLines.join('\n');

    // Clean up extra blank lines
    content = content.replaceAll(RegExp(r'\n\n\n+'), '\n\n');

    routesFile.writeAsStringSync(content);
  }

  void _removeFeatureDirectory() {
    print('📁 Removing feature directory...');

    final featureDir = Directory('lib/features/$featureName');
    if (featureDir.existsSync()) {
      try {
        featureDir.deleteSync(recursive: true);
        print('   ✅ Deleted: ${featureDir.path}');
      } catch (e) {
        print('   ⚠️  Warning: Could not delete directory: $e');
        print('   Please manually delete: ${featureDir.path}');
      }
    } else {
      print('   ℹ️  Directory does not exist: ${featureDir.path}');
    }
  }
}
