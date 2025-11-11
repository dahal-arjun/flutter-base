#!/usr/bin/env dart

import 'dart:io';

/// Script to create a new feature following Clean Architecture pattern
/// Usage: dart run scripts/create_feature.dart <feature_name>
/// Example: dart run scripts/create_feature.dart products

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Error: Feature name is required');
    print('Usage: dart run scripts/create_feature.dart <feature_name>');
    print('Example: dart run scripts/create_feature.dart products');
    exit(1);
  }

  final featureName = args[0].toLowerCase();
  final featureGenerator = FeatureGenerator(featureName);
  featureGenerator.generate();
}

class FeatureGenerator {
  final String featureName;
  final String featureNamePascal;
  final String featureNameCamel;
  final String featureNamePlural;
  final String featureNamePluralPascal;

  FeatureGenerator(this.featureName)
    : featureNamePascal = _toPascalCase(featureName),
      featureNameCamel = _toCamelCase(featureName),
      featureNamePlural = _pluralize(featureName),
      featureNamePluralPascal = _toPascalCase(_pluralize(featureName));

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

  void generate() {
    print('🚀 Creating feature: $featureNamePascal\n');

    try {
      _createDirectories();
      _createDomainLayer();
      _createDataLayer();
      _createPresentationLayer();
      _updateDependencyInjection();
      _updateRouter();
      _updateRoutes();

      print('\n✅ Feature "$featureNamePascal" created successfully!');
      print('\n📝 Next steps:');
      print(
        '1. Run: flutter pub run build_runner build --delete-conflicting-outputs',
      );
      print('2. Update the entity class with your fields');
      print('3. Update the repository interface with your methods');
      print('4. Implement your use cases');
      print('5. Update data sources with your API endpoints');
      print('6. Customize your BLoC events and states');
      print('7. Build your UI in the page widget');
    } catch (e) {
      print('❌ Error creating feature: $e');
      exit(1);
    }
  }

  void _createDirectories() {
    print('📁 Creating directory structure...');

    final directories = [
      'lib/features/$featureName/data/datasources',
      'lib/features/$featureName/data/models',
      'lib/features/$featureName/data/repositories',
      'lib/features/$featureName/domain/entities',
      'lib/features/$featureName/domain/repositories',
      'lib/features/$featureName/domain/usecases',
      'lib/features/$featureName/presentation/bloc',
      'lib/features/$featureName/presentation/pages',
      'lib/features/$featureName/presentation/widgets',
    ];

    for (final dir in directories) {
      Directory(dir).createSync(recursive: true);
    }
  }

  void _createDomainLayer() {
    print('📦 Creating domain layer...');

    // Entity
    final entityFile = File(
      'lib/features/$featureName/domain/entities/${featureName}_entity.dart',
    );
    entityFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';

/// ${featureNamePascal} entity
/// Represents a ${featureName} in the domain layer
class ${featureNamePascal}Entity extends Equatable {
  final String id;
  final String name;

  const ${featureNamePascal}Entity({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];
}
''');

    // Repository Interface
    final repositoryFile = File(
      'lib/features/$featureName/domain/repositories/${featureName}_repository.dart',
    );
    repositoryFile.writeAsStringSync('''
import '../../../../core/utils/typedefs.dart';
import '../entities/${featureName}_entity.dart';

/// Repository interface for ${featureNamePascal}
/// Defines the contract for ${featureName} data operations
abstract class ${featureNamePascal}Repository {
  /// Get all ${featureNamePlural}
  ResultFuture<List<${featureNamePascal}Entity>> get${featureNamePluralPascal}();
  
  /// Get ${featureName} by ID
  ResultFuture<${featureNamePascal}Entity> get${featureNamePascal}ById(String id);
  
  /// Create a new ${featureName}
  ResultFuture<${featureNamePascal}Entity> create${featureNamePascal}(${featureNamePascal}Entity ${featureNameCamel});
  
  /// Update an existing ${featureName}
  ResultFuture<${featureNamePascal}Entity> update${featureNamePascal}(${featureNamePascal}Entity ${featureNameCamel});
  
  /// Delete a ${featureName}
  ResultFuture<void> delete${featureNamePascal}(String id);
}
''');

    // Use Case - Get All
    final getUseCaseFile = File(
      'lib/features/$featureName/domain/usecases/get_${featureNamePlural}_usecase.dart',
    );
    getUseCaseFile.writeAsStringSync('''
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for getting all ${featureNamePlural}
class Get${featureNamePluralPascal}UseCase implements UseCase<List<${featureNamePascal}Entity>, NoParams> {
  final ${featureNamePascal}Repository repository;

  Get${featureNamePluralPascal}UseCase(this.repository);

  @override
  ResultFuture<List<${featureNamePascal}Entity>> call(NoParams params) async {
    return await repository.get${featureNamePluralPascal}();
  }
}
''');

    // Use Case - Get By ID
    final getByIdUseCaseFile = File(
      'lib/features/$featureName/domain/usecases/get_${featureName}_by_id_usecase.dart',
    );
    getByIdUseCaseFile.writeAsStringSync('''
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for getting a ${featureName} by ID
class Get${featureNamePascal}ByIdUseCase implements UseCase<${featureNamePascal}Entity, Get${featureNamePascal}ByIdParams> {
  final ${featureNamePascal}Repository repository;

  Get${featureNamePascal}ByIdUseCase(this.repository);

  @override
  ResultFuture<${featureNamePascal}Entity> call(Get${featureNamePascal}ByIdParams params) async {
    return await repository.get${featureNamePascal}ById(params.id);
  }
}

/// Parameters for Get${featureNamePascal}ByIdUseCase
class Get${featureNamePascal}ByIdParams extends Equatable {
  final String id;

  const Get${featureNamePascal}ByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
''');
  }

  void _createDataLayer() {
    print('💾 Creating data layer...');

    // Model
    final modelFile = File(
      'lib/features/$featureName/data/models/${featureName}_model.dart',
    );
    modelFile.writeAsStringSync('''
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/${featureName}_entity.dart';

part '${featureName}_model.g.dart';

/// ${featureNamePascal} model
/// Data transfer object for ${featureName}
@JsonSerializable()
class ${featureNamePascal}Model extends ${featureNamePascal}Entity {
  const ${featureNamePascal}Model({
    required super.id,
    required super.name,
  });

  /// Create model from JSON
  factory ${featureNamePascal}Model.fromJson(Map<String, dynamic> json) =>
      _\$${featureNamePascal}ModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _\$${featureNamePascal}ModelToJson(this);

  /// Convert model to entity
  ${featureNamePascal}Entity toEntity() {
    return ${featureNamePascal}Entity(
      id: id,
      name: name,
    );
  }
}
''');

    // Remote Data Source
    final remoteDataSourceFile = File(
      'lib/features/$featureName/data/datasources/${featureName}_remote_data_source.dart',
    );
    remoteDataSourceFile.writeAsStringSync('''
import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/${featureName}_model.dart';

/// Remote data source interface for ${featureNamePascal}
abstract class ${featureNamePascal}RemoteDataSource {
  /// Get all ${featureNamePlural} from remote
  Future<List<${featureNamePascal}Model>> get${featureNamePluralPascal}();
  
  /// Get ${featureName} by ID from remote
  Future<${featureNamePascal}Model> get${featureNamePascal}ById(String id);
  
  /// Create ${featureName} on remote
  Future<${featureNamePascal}Model> create${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel});
  
  /// Update ${featureName} on remote
  Future<${featureNamePascal}Model> update${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel});
  
  /// Delete ${featureName} from remote
  Future<void> delete${featureNamePascal}(String id);
}

/// Implementation of ${featureNamePascal}RemoteDataSource
class ${featureNamePascal}RemoteDataSourceImpl extends RemoteDataSource
    implements ${featureNamePascal}RemoteDataSource {
  ${featureNamePascal}RemoteDataSourceImpl(super.httpClient);

  @override
  Future<List<${featureNamePascal}Model>> get${featureNamePluralPascal}() async {
    try {
      final response = await get('/${featureNamePlural}');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ${featureNamePascal}Model.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to fetch ${featureNamePlural}');
      }
    } catch (e) {
      throw ServerException('Error fetching ${featureNamePlural}: \${e.toString()}');
    }
  }

  @override
  Future<${featureNamePascal}Model> get${featureNamePascal}ById(String id) async {
    try {
      final response = await get('/${featureNamePlural}/\$id');
      if (response.statusCode == 200 && response.data != null) {
        return ${featureNamePascal}Model.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to fetch ${featureName}');
      }
    } catch (e) {
      throw ServerException('Error fetching ${featureName}: \${e.toString()}');
    }
  }

  @override
  Future<${featureNamePascal}Model> create${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel}) async {
    try {
      final response = await post('/${featureNamePlural}', data: ${featureNameCamel}.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ${featureNamePascal}Model.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to create ${featureName}');
      }
    } catch (e) {
      throw ServerException('Error creating ${featureName}: \${e.toString()}');
    }
  }

  @override
  Future<${featureNamePascal}Model> update${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel}) async {
    try {
      final response = await put('/${featureNamePlural}/\${${featureNameCamel}.id}', data: ${featureNameCamel}.toJson());
      if (response.statusCode == 200) {
        return ${featureNamePascal}Model.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to update ${featureName}');
      }
    } catch (e) {
      throw ServerException('Error updating ${featureName}: \${e.toString()}');
    }
  }

  @override
  Future<void> delete${featureNamePascal}(String id) async {
    try {
      final response = await delete('/${featureNamePlural}/\$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete ${featureName}');
      }
    } catch (e) {
      throw ServerException('Error deleting ${featureName}: \${e.toString()}');
    }
  }
}
''');

    // Local Data Source
    final localDataSourceFile = File(
      'lib/features/$featureName/data/datasources/${featureName}_local_data_source.dart',
    );
    localDataSourceFile.writeAsStringSync('''
import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/${featureName}_model.dart';

/// Local data source interface for ${featureNamePascal}
abstract class ${featureNamePascal}LocalDataSource {
  /// Cache ${featureNamePlural}
  Future<void> cache${featureNamePluralPascal}(List<${featureNamePascal}Model> ${featureNamePluralCamel});
  
  /// Get cached ${featureNamePlural}
  Future<List<${featureNamePascal}Model>?> getCached${featureNamePluralPascal}();
  
  /// Cache a single ${featureName}
  Future<void> cache${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel});
  
  /// Get cached ${featureName} by ID
  Future<${featureNamePascal}Model?> getCached${featureNamePascal}(String id);
  
  /// Clear cache
  Future<void> clearCache();
}

/// Implementation of ${featureNamePascal}LocalDataSource
class ${featureNamePascal}LocalDataSourceImpl extends LocalDataSource
    implements ${featureNamePascal}LocalDataSource {
  static const String _${featureNamePluralCamel}CacheKey = 'cached_${featureNamePlural}';
  static const String _${featureNameCamel}CachePrefix = 'cached_${featureName}_';

  ${featureNamePascal}LocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  /// Recursively converts Map with dynamic types to Map<String, dynamic>
  Map<String, dynamic> _convertMap(Map map) {
    return Map<String, dynamic>.from(
      map.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _convertMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((item) => item is Map ? _convertMap(item) : item).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      }),
    );
  }

  @override
  Future<void> cache${featureNamePluralPascal}(List<${featureNamePascal}Model> ${featureNamePluralCamel}) async {
    try {
      final jsonList = ${featureNamePluralCamel}.map((model) => model.toJson()).toList();
      await setHiveData(_${featureNamePluralCamel}CacheKey, jsonList);
      
      // Also cache individual ${featureNamePlural}
      for (final ${featureNameCamel} in ${featureNamePluralCamel}) {
        await setHiveData('\$_${featureNameCamel}CachePrefix\${${featureNameCamel}.id}', ${featureNameCamel}.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache ${featureNamePlural}: \${e.toString()}');
    }
  }

  @override
  Future<List<${featureNamePascal}Model>?> getCached${featureNamePluralPascal}() async {
    try {
      final jsonList = getHiveData<List<dynamic>>(_${featureNamePluralCamel}CacheKey);
      if (jsonList != null) {
        return jsonList
            .map((json) {
              final ${featureNameCamel}Map = json as Map;
              final convertedMap = _convertMap(${featureNameCamel}Map);
              return ${featureNamePascal}Model.fromJson(convertedMap);
            })
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached ${featureNamePlural}: \${e.toString()}');
    }
  }

  @override
  Future<void> cache${featureNamePascal}(${featureNamePascal}Model ${featureNameCamel}) async {
    try {
      await setHiveData('\$_${featureNameCamel}CachePrefix\${${featureNameCamel}.id}', ${featureNameCamel}.toJson());
    } catch (e) {
      throw CacheException('Failed to cache ${featureName}: \${e.toString()}');
    }
  }

  @override
  Future<${featureNamePascal}Model?> getCached${featureNamePascal}(String id) async {
    try {
      final ${featureNameCamel}Json = getHiveData<Map>('\$_${featureNameCamel}CachePrefix\$id');
      if (${featureNameCamel}Json != null) {
        final convertedMap = _convertMap(${featureNameCamel}Json);
        return ${featureNamePascal}Model.fromJson(convertedMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached ${featureName}: \${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteHiveData(_${featureNamePluralCamel}CacheKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: \${e.toString()}');
    }
  }
}
''');

    // Repository Implementation
    final repositoryImplFile = File(
      'lib/features/$featureName/data/repositories/${featureName}_repository_impl.dart',
    );
    repositoryImplFile.writeAsStringSync('''
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../datasources/${featureName}_local_data_source.dart';
import '../datasources/${featureName}_remote_data_source.dart';
import '../models/${featureName}_model.dart';

/// Implementation of ${featureNamePascal}Repository
class ${featureNamePascal}RepositoryImpl with BaseRepository implements ${featureNamePascal}Repository {
  final ${featureNamePascal}RemoteDataSource remoteDataSource;
  final ${featureNamePascal}LocalDataSource localDataSource;

  ${featureNamePascal}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<List<${featureNamePascal}Entity>> get${featureNamePluralPascal}() async {
    return handleException(() async {
      final connectivityService = di.getIt<ConnectivityService>();
      final isOnline =
          connectivityService.currentStatus == NetworkStatus.online;

      final cached${featureNamePluralPascal} = await localDataSource.getCached${featureNamePluralPascal}();
      if (cached${featureNamePluralPascal} != null && cached${featureNamePluralPascal}.isNotEmpty) {
        if (isOnline) {
          _refresh${featureNamePluralPascal}InBackground();
        }
        return cached${featureNamePluralPascal}.map((model) => model.toEntity()).toList();
      }

      if (!isOnline) {
        throw Exception(
          'No internet connection. Please connect to the internet to load ${featureNamePlural}.',
        );
      }

      final remote${featureNamePluralPascal} = await remoteDataSource.get${featureNamePluralPascal}();
      await localDataSource.cache${featureNamePluralPascal}(remote${featureNamePluralPascal});
      return remote${featureNamePluralPascal}.map((model) => model.toEntity()).toList();
    });
  }

  @override
  ResultFuture<${featureNamePascal}Entity> get${featureNamePascal}ById(String id) async {
    return handleException(() async {
      final cached${featureNamePascal} = await localDataSource.getCached${featureNamePascal}(id);
      if (cached${featureNamePascal} != null) {
        _refresh${featureNamePascal}InBackground(id);
        return cached${featureNamePascal}.toEntity();
      }

      final remote${featureNamePascal} = await remoteDataSource.get${featureNamePascal}ById(id);
      await localDataSource.cache${featureNamePascal}(remote${featureNamePascal});
      return remote${featureNamePascal}.toEntity();
    });
  }

  @override
  ResultFuture<${featureNamePascal}Entity> create${featureNamePascal}(${featureNamePascal}Entity ${featureNameCamel}) async {
    return handleException(() async {
      final ${featureNameCamel}Model = ${featureNamePascal}Model(
        id: ${featureNameCamel}.id,
        name: ${featureNameCamel}.name,
      );
      final created${featureNamePascal} = await remoteDataSource.create${featureNamePascal}(${featureNameCamel}Model);
      await localDataSource.cache${featureNamePascal}(created${featureNamePascal});
      return created${featureNamePascal}.toEntity();
    });
  }

  @override
  ResultFuture<${featureNamePascal}Entity> update${featureNamePascal}(${featureNamePascal}Entity ${featureNameCamel}) async {
    return handleException(() async {
      final ${featureNameCamel}Model = ${featureNamePascal}Model(
        id: ${featureNameCamel}.id,
        name: ${featureNameCamel}.name,
      );
      final updated${featureNamePascal} = await remoteDataSource.update${featureNamePascal}(${featureNameCamel}Model);
      await localDataSource.cache${featureNamePascal}(updated${featureNamePascal});
      return updated${featureNamePascal}.toEntity();
    });
  }

  @override
  ResultFuture<void> delete${featureNamePascal}(String id) async {
    return handleException(() async {
      await remoteDataSource.delete${featureNamePascal}(id);
      // Optionally clear from cache
    });
  }

  /// Refresh ${featureNamePlural} in the background without blocking the UI
  Future<void> _refresh${featureNamePluralPascal}InBackground() async {
    try {
      final connectivityService = di.getIt<ConnectivityService>();
      if (connectivityService.currentStatus == NetworkStatus.online) {
        final remote${featureNamePluralPascal} = await remoteDataSource.get${featureNamePluralPascal}();
        await localDataSource.cache${featureNamePluralPascal}(remote${featureNamePluralPascal});
      }
    } catch (e) {
      AppLogger.w('Background ${featureNamePlural} refresh failed', e);
    }
  }

  /// Refresh a single ${featureName} in the background without blocking the UI
  Future<void> _refresh${featureNamePascal}InBackground(String id) async {
    try {
      final remote${featureNamePascal} = await remoteDataSource.get${featureNamePascal}ById(id);
      await localDataSource.cache${featureNamePascal}(remote${featureNamePascal});
    } catch (e) {
      AppLogger.w('Background ${featureName} refresh failed for id \$id', e);
    }
  }
}
''');
  }

  void _createPresentationLayer() {
    print('🎨 Creating presentation layer...');

    // BLoC Events
    final eventFile = File(
      'lib/features/$featureName/presentation/bloc/${featureName}_event.dart',
    );
    eventFile.writeAsStringSync('''
part of '${featureName}_bloc.dart';

/// Events for ${featureNamePascal}Bloc
abstract class ${featureNamePascal}Event extends Equatable {
  const ${featureNamePascal}Event();

  @override
  List<Object> get props => [];
}

/// Event to request ${featureNamePlural}
class Get${featureNamePluralPascal}Requested extends ${featureNamePascal}Event {
  const Get${featureNamePluralPascal}Requested();
}

/// Event to refresh ${featureNamePlural}
class Refresh${featureNamePluralPascal}Requested extends ${featureNamePascal}Event {
  const Refresh${featureNamePluralPascal}Requested();
}

/// Event to get ${featureName} by ID
class Get${featureNamePascal}ByIdRequested extends ${featureNamePascal}Event {
  final String id;
  const Get${featureNamePascal}ByIdRequested(this.id);

  @override
  List<Object> get props => [id];
}
''');

    // BLoC States
    final stateFile = File(
      'lib/features/$featureName/presentation/bloc/${featureName}_state.dart',
    );
    stateFile.writeAsStringSync('''
part of '${featureName}_bloc.dart';

/// States for ${featureNamePascal}Bloc
abstract class ${featureNamePascal}State extends Equatable {
  const ${featureNamePascal}State();

  @override
  List<Object> get props => [];
}

/// Initial state
class ${featureNamePascal}Initial extends ${featureNamePascal}State {}

/// Loading state
class ${featureNamePascal}Loading extends ${featureNamePascal}State {}

/// Refreshing state (shows cached data while refreshing)
class ${featureNamePascal}Refreshing extends ${featureNamePascal}State {
  final List<${featureNamePascal}Entity> ${featureNamePluralCamel};
  const ${featureNamePascal}Refreshing(this.${featureNamePluralCamel});

  @override
  List<Object> get props => [${featureNamePluralCamel}];
}

/// Loaded state
class ${featureNamePascal}Loaded extends ${featureNamePascal}State {
  final List<${featureNamePascal}Entity> ${featureNamePluralCamel};
  const ${featureNamePascal}Loaded(this.${featureNamePluralCamel});

  @override
  List<Object> get props => [${featureNamePluralCamel}];
}

/// Error state
class ${featureNamePascal}Error extends ${featureNamePascal}State {
  final String message;
  const ${featureNamePascal}Error(this.message);

  @override
  List<Object> get props => [message];
}
''');

    // BLoC
    final blocFile = File(
      'lib/features/$featureName/presentation/bloc/${featureName}_bloc.dart',
    );
    blocFile.writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/usecases/get_${featureNamePlural}_usecase.dart';
import '../../domain/usecases/get_${featureName}_by_id_usecase.dart';

part '${featureName}_event.dart';
part '${featureName}_state.dart';

/// BLoC for managing ${featureNamePascal} state
class ${featureNamePascal}Bloc extends Bloc<${featureNamePascal}Event, ${featureNamePascal}State> {
  final Get${featureNamePluralPascal}UseCase get${featureNamePluralPascal}UseCase;
  final Get${featureNamePascal}ByIdUseCase get${featureNamePascal}ByIdUseCase;

  ${featureNamePascal}Bloc({
    required this.get${featureNamePluralPascal}UseCase,
    required this.get${featureNamePascal}ByIdUseCase,
  }) : super(${featureNamePascal}Initial()) {
    on<Get${featureNamePluralPascal}Requested>(_onGet${featureNamePluralPascal}Requested);
    on<Refresh${featureNamePluralPascal}Requested>(_onRefresh${featureNamePluralPascal}Requested);
    on<Get${featureNamePascal}ByIdRequested>(_onGet${featureNamePascal}ByIdRequested);
  }

  Future<void> _onGet${featureNamePluralPascal}Requested(
    Get${featureNamePluralPascal}Requested event,
    Emitter<${featureNamePascal}State> emit,
  ) async {
    emit(${featureNamePascal}Loading());

    final result = await get${featureNamePluralPascal}UseCase(NoParams());

    result.fold(
      (failure) => emit(${featureNamePascal}Error(failure.message)),
      (${featureNamePluralCamel}) => emit(${featureNamePascal}Loaded(${featureNamePluralCamel})),
    );
  }

  Future<void> _onRefresh${featureNamePluralPascal}Requested(
    Refresh${featureNamePluralPascal}Requested event,
    Emitter<${featureNamePascal}State> emit,
  ) async {
    if (state is ${featureNamePascal}Loaded) {
      emit(${featureNamePascal}Refreshing((state as ${featureNamePascal}Loaded).${featureNamePluralCamel}));
    } else {
      emit(${featureNamePascal}Loading());
    }

    final result = await get${featureNamePluralPascal}UseCase(NoParams());

    result.fold(
      (failure) => emit(${featureNamePascal}Error(failure.message)),
      (${featureNamePluralCamel}) => emit(${featureNamePascal}Loaded(${featureNamePluralCamel})),
    );
  }

  Future<void> _onGet${featureNamePascal}ByIdRequested(
    Get${featureNamePascal}ByIdRequested event,
    Emitter<${featureNamePascal}State> emit,
  ) async {
    emit(${featureNamePascal}Loading());

    final result = await get${featureNamePascal}ByIdUseCase(Get${featureNamePascal}ByIdParams(id: event.id));

    result.fold(
      (failure) => emit(${featureNamePascal}Error(failure.message)),
      (${featureNameCamel}) {
        // You might want to handle single ${featureName} differently
        emit(${featureNamePascal}Loaded([${featureNameCamel}]));
      },
    );
  }
}
''');

    // Page
    final pageFile = File(
      'lib/features/$featureName/presentation/pages/${featureNamePlural}_page.dart',
    );
    pageFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/${featureName}_entity.dart';
import '../bloc/${featureName}_bloc.dart';

/// Page displaying list of ${featureNamePlural}
class ${featureNamePluralPascal}Page extends StatelessWidget {
  const ${featureNamePluralPascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<${featureNamePascal}Bloc>()..add(Get${featureNamePluralPascal}Requested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('${featureNamePluralPascal}'),
        ),
        body: BlocBuilder<${featureNamePascal}Bloc, ${featureNamePascal}State>(
          builder: (context, state) {
            if (state is ${featureNamePascal}Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ${featureNamePascal}Refreshing) {
              return Stack(
                children: [
                  _build${featureNamePluralPascal}List(state.${featureNamePluralCamel}),
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            } else if (state is ${featureNamePascal}Loaded) {
              if (state.${featureNamePluralCamel}.isEmpty) {
                return const Center(child: Text('No ${featureNamePlural} found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<${featureNamePascal}Bloc>().add(Refresh${featureNamePluralPascal}Requested());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _build${featureNamePluralPascal}List(state.${featureNamePluralCamel}),
              );
            } else if (state is ${featureNamePascal}Error) {
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
                      'Error: \${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<${featureNamePascal}Bloc>().add(Get${featureNamePluralPascal}Requested());
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

  Widget _build${featureNamePluralPascal}List(List<${featureNamePascal}Entity> ${featureNamePluralCamel}) {
    return ListView.builder(
      itemCount: ${featureNamePluralCamel}.length,
      itemBuilder: (context, index) {
        final ${featureNameCamel} = ${featureNamePluralCamel}[index];
        return ListTile(
          title: Text(${featureNameCamel}.name),
          subtitle: Text('ID: \${${featureNameCamel}.id}'),
          onTap: () {
            // Handle tap
          },
        );
      },
    );
  }
}
''');
  }

  void _updateDependencyInjection() {
    print('🔌 Updating dependency injection...');

    final diFile = File('lib/core/di/injection_container.dart');
    var content = diFile.readAsStringSync();

    // Add imports before the Network import
    final importSection =
        '// Network\nimport \'../../core/network/connectivity_service.dart\';';
    final newImports =
        '''
// ${featureNamePascal} Feature
import '../../features/$featureName/data/datasources/${featureName}_local_data_source.dart';
import '../../features/$featureName/data/datasources/${featureName}_remote_data_source.dart';
import '../../features/$featureName/data/repositories/${featureName}_repository_impl.dart';
import '../../features/$featureName/domain/repositories/${featureName}_repository.dart';
import '../../features/$featureName/domain/usecases/get_${featureNamePlural}_usecase.dart';
import '../../features/$featureName/domain/usecases/get_${featureName}_by_id_usecase.dart';
import '../../features/$featureName/presentation/bloc/${featureName}_bloc.dart';

$importSection
''';

    content = content.replaceAll(importSection, newImports);

    // Add registration before the Network Services section
    final networkSection = '  // ========== Network Services ==========';
    final newRegistration =
        '''
  // ========== ${featureNamePascal} Feature ==========

  // Data Sources
  getIt.registerLazySingleton<${featureNamePascal}RemoteDataSource>(
    () => ${featureNamePascal}RemoteDataSourceImpl(getIt<HttpClientService>()),
  );
  getIt.registerLazySingleton<${featureNamePascal}LocalDataSource>(
    () => ${featureNamePascal}LocalDataSourceImpl(
      hiveStorage: getIt<HiveStorageService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<${featureNamePascal}Repository>(
    () => ${featureNamePascal}RepositoryImpl(
      remoteDataSource: getIt<${featureNamePascal}RemoteDataSource>(),
      localDataSource: getIt<${featureNamePascal}LocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<Get${featureNamePluralPascal}UseCase>(
    () => Get${featureNamePluralPascal}UseCase(getIt<${featureNamePascal}Repository>()),
  );
  getIt.registerLazySingleton<Get${featureNamePascal}ByIdUseCase>(
    () => Get${featureNamePascal}ByIdUseCase(getIt<${featureNamePascal}Repository>()),
  );

  // BLoC
  getIt.registerFactory<${featureNamePascal}Bloc>(
    () => ${featureNamePascal}Bloc(
      get${featureNamePluralPascal}UseCase: getIt<Get${featureNamePluralPascal}UseCase>(),
      get${featureNamePascal}ByIdUseCase: getIt<Get${featureNamePascal}ByIdUseCase>(),
    ),
  );

$networkSection
''';

    content = content.replaceAll(networkSection, newRegistration);
    diFile.writeAsStringSync(content);
  }

  void _updateRouter() {
    print('🛣️  Updating router...');

    final routerFile = File('lib/core/router/app_router.dart');
    var content = routerFile.readAsStringSync();

    // Add import
    final lastImport =
        'import \'../../features/posts/presentation/pages/post_detail_page_wrapper.dart\';';
    final newImport = '''$lastImport
import '../../features/$featureName/presentation/pages/${featureNamePlural}_page.dart';''';

    content = content.replaceAll(lastImport, newImport);

    // Add route before the closing bracket of routes
    final routesEnd = '      ),\n    ],\n    errorBuilder:';
    final newRoute =
        '''      ),
      GoRoute(
        path: AppRoutes.${featureNamePluralCamel},
        name: AppRoutes.${featureNamePluralCamel}Name,
        builder: (context, state) => const ${featureNamePluralPascal}Page(),
      ),
    ],
    errorBuilder:''';

    content = content.replaceAll(routesEnd, newRoute);
    routerFile.writeAsStringSync(content);
  }

  void _updateRoutes() {
    print('📍 Updating route constants...');

    final routesFile = File('lib/core/router/app_routes.dart');
    var content = routesFile.readAsStringSync();

    // Add route path constant
    final lastRoutePath = '  static const String posts = \'/posts\';';
    final newRoutePath = '''$lastRoutePath
  static const String $featureNamePluralCamel = '/$featureNamePlural';''';

    content = content.replaceAll(lastRoutePath, newRoutePath);

    // Add route name constant
    final lastRouteName =
        '  static const String postDetailName = \'post-detail\';';
    final newRouteName = '''$lastRouteName
  static const String ${featureNamePluralCamel}Name = '$featureNamePlural';''';

    content = content.replaceAll(lastRouteName, newRouteName);

    routesFile.writeAsStringSync(content);
  }

  String get featureNamePluralCamel => _toCamelCase(featureNamePlural);
}
