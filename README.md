# CP App

A Flutter application built with **Clean Architecture** principles and **feature-based** organization, ensuring separation of concerns, testability, and maintainability.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Adding a New Feature](#adding-a-new-feature)
- [Key Principles](#key-principles)
- [Error Handling](#error-handling)
- [Testing Strategy](#testing-strategy)

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **feature-based** organization.

### Architecture Layers

#### 1. **Domain Layer** (Business Logic)
- **Entities**: Pure business objects, no dependencies
- **Repositories**: Interfaces defining data contracts
- **Use Cases**: Single responsibility business operations

**Dependencies**: None (pure Dart)

#### 2. **Data Layer** (Data Management)
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: Remote (API) and Local (Cache) implementations
- **Repository Implementations**: Implement domain repository interfaces

**Dependencies**: Domain layer only

#### 3. **Presentation Layer** (UI)
- **BLoC**: State management
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components

**Dependencies**: Domain layer only

### Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↑        ↓
   BLoC      Use Cases  Models
     ↓           ↑        ↓
   Pages    Entities  DataSources
```

**Key Rule**: Dependencies point inward. Outer layers depend on inner layers, never the reverse.

## 📁 Project Structure

```
lib/
├── core/                           # Core/shared infrastructure
│   ├── constants/                  # App-wide constants
│   ├── di/                         # Dependency injection setup
│   ├── error/                      # Error handling (failures, exceptions)
│   ├── router/                     # App routing configuration
│   ├── usecases/                   # Base use case classes
│   └── utils/                      # Utility types and helpers
│
├── features/                       # Feature modules (feature-based)
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Data sources (remote & local)
│   │   │   ├── models/             # Data models (JSON serializable)
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/                 # Domain layer (business logic)
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Use cases (business rules)
│   │   └── presentation/           # Presentation layer (UI)
│   │       ├── bloc/               # BLoC (state management)
│   │       ├── pages/              # Feature pages/screens
│   │       └── widgets/            # Feature-specific widgets
│   │
│   ├── posts/                      # Posts feature
│   ├── users/                      # Users feature
│   ├── comments/                   # Comments feature
│   ├── dashboard/                  # Dashboard feature
│   └── splash/                     # Splash feature
│
├── shared/                         # Shared across features
│   ├── data/                       # Shared data layer components
│   │   ├── datasources/            # Base data sources
│   │   └── repositories/           # Base repository mixin
│   └── presentation/               # Shared presentation components
│       └── widgets/                # Shared widgets
│
├── services/                       # External services (infrastructure)
│   ├── auth/                       # Biometric auth service
│   ├── camera/                     # Camera service
│   ├── http/                       # HTTP client service
│   ├── notifications/              # Notification services
│   ├── storage/                    # Storage services
│   ├── language/                   # Language service
│   └── theme/                      # Theme service
│
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation (for JSON serialization):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Configuration

1. **Firebase Setup** (Optional):
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Uncomment Firebase initialization code in `lib/core/di/injection_container.dart`

2. **API Configuration**:
   - Update `lib/core/constants/app_constants.dart` with your API base URL

## ➕ Adding a New Feature

### Quick Start: Use the Feature Generator Script

The easiest way to create a new feature is to use the automated feature generator script:

```bash
# Using Dart directly
dart run scripts/create_feature.dart <feature_name>

# Or using the bash wrapper
./scripts/create_feature.sh <feature_name>

# Example
dart run scripts/create_feature.dart products
```

This script will automatically:
- ✅ Create all necessary directories
- ✅ Generate all template files (Entity, Repository, Use Cases, Models, Data Sources, BLoC, Page)
- ✅ Update dependency injection configuration
- ✅ Update router configuration
- ✅ Update route constants

After running the script, you'll need to:
1. Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
2. Customize the entity with your fields
3. Update API endpoints in remote data source
4. Customize BLoC events and states as needed
5. Build your UI in the page widget

### Manual Setup (Alternative)

If you prefer to create a feature manually, follow these steps:

#### Step 1: Create Feature Structure

```bash
mkdir -p lib/features/your_feature/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

#### Step 2: Domain Layer (Start Here)

**1. Create Entity** (`domain/entities/your_entity.dart`):
```dart
import 'package:equatable/equatable.dart';

class YourEntity extends Equatable {
  final String id;
  final String name;

  const YourEntity({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
```

**2. Create Repository Interface** (`domain/repositories/your_repository.dart`):
```dart
import '../../../../core/utils/typedefs.dart';
import '../entities/your_entity.dart';

abstract class YourRepository {
  ResultFuture<YourEntity> getEntity(String id);
  ResultFuture<List<YourEntity>> getAll();
}
```

**3. Create Use Case** (`domain/usecases/get_entity_usecase.dart`):
```dart
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/your_entity.dart';
import '../repositories/your_repository.dart';

class GetEntityUseCase implements UseCase<YourEntity, GetEntityParams> {
  final YourRepository repository;

  GetEntityUseCase(this.repository);

  @override
  ResultFuture<YourEntity> call(GetEntityParams params) async {
    return await repository.getEntity(params.id);
  }
}

class GetEntityParams extends Equatable {
  final String id;

  const GetEntityParams({required this.id});

  @override
  List<Object> get props => [id];
}
```

### Step 3: Data Layer

**1. Create Model** (`data/models/your_entity_model.dart`):
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/your_entity.dart';

part 'your_entity_model.g.dart';

@JsonSerializable()
class YourEntityModel extends YourEntity {
  const YourEntityModel({
    required super.id,
    required super.name,
  });

  factory YourEntityModel.fromJson(Map<String, dynamic> json) =>
      _$YourEntityModelFromJson(json);

  Map<String, dynamic> toJson() => _$YourEntityModelToJson(this);

  YourEntity toEntity() {
    return YourEntity(id: id, name: name);
  }
}
```

**2. Create Remote Data Source** (`data/datasources/your_remote_data_source.dart`):
```dart
import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/your_entity_model.dart';

abstract class YourRemoteDataSource {
  Future<YourEntityModel> getEntity(String id);
}

class YourRemoteDataSourceImpl extends RemoteDataSource
    implements YourRemoteDataSource {
  YourRemoteDataSourceImpl(super.httpClient);

  @override
  Future<YourEntityModel> getEntity(String id) async {
    try {
      final response = await get('/entities/$id');
      if (response.statusCode == 200 && response.data != null) {
        return YourEntityModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to fetch entity');
      }
    } catch (e) {
      throw ServerException('Error fetching entity: ${e.toString()}');
    }
  }
}
```

**3. Create Local Data Source** (`data/datasources/your_local_data_source.dart`):
```dart
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/your_entity_model.dart';

abstract class YourLocalDataSource {
  Future<void> cacheEntity(YourEntityModel entity);
  Future<YourEntityModel?> getCachedEntity(String id);
}

class YourLocalDataSourceImpl extends LocalDataSource
    implements YourLocalDataSource {
  YourLocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  @override
  Future<void> cacheEntity(YourEntityModel entity) async {
    await setHiveData('entity_${entity.id}', entity.toJson());
  }

  @override
  Future<YourEntityModel?> getCachedEntity(String id) async {
    final json = getHiveData<Map<String, dynamic>>('entity_$id');
    return json != null ? YourEntityModel.fromJson(json) : null;
  }
}
```

**4. Implement Repository** (`data/repositories/your_repository_impl.dart`):
```dart
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/your_entity.dart';
import '../../domain/repositories/your_repository.dart';
import '../datasources/your_local_data_source.dart';
import '../datasources/your_remote_data_source.dart';

class YourRepositoryImpl with BaseRepository implements YourRepository {
  final YourRemoteDataSource remoteDataSource;
  final YourLocalDataSource localDataSource;

  YourRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<YourEntity> getEntity(String id) async {
    return handleException(() async {
      // Try cache first
      final cached = await localDataSource.getCachedEntity(id);
      if (cached != null) {
        return cached.toEntity();
      }

      // Fetch from remote
      final remote = await remoteDataSource.getEntity(id);
      await localDataSource.cacheEntity(remote);
      return remote.toEntity();
    });
  }

  @override
  ResultFuture<List<YourEntity>> getAll() async {
    return handleException(() async {
      final remote = await remoteDataSource.getAll();
      return remote.map((model) => model.toEntity()).toList();
    });
  }
}
```

### Step 4: Presentation Layer

**1. Create BLoC** (`presentation/bloc/your_bloc.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/your_entity.dart';
import '../../domain/usecases/get_entity_usecase.dart';

part 'your_event.dart';
part 'your_state.dart';

class YourBloc extends Bloc<YourEvent, YourState> {
  final GetEntityUseCase getEntityUseCase;

  YourBloc({required this.getEntityUseCase}) : super(YourInitial()) {
    on<GetEntityRequested>(_onGetEntityRequested);
  }

  Future<void> _onGetEntityRequested(
    GetEntityRequested event,
    Emitter<YourState> emit,
  ) async {
    emit(YourLoading());

    final result = await getEntityUseCase(GetEntityParams(id: event.id));

    result.fold(
      (failure) => emit(YourError(failure.message)),
      (entity) => emit(YourLoaded(entity)),
    );
  }
}
```

**2. Create Events & States**:
```dart
// your_event.dart
part of 'your_bloc.dart';

abstract class YourEvent extends Equatable {
  const YourEvent();
  @override
  List<Object> get props => [];
}

class GetEntityRequested extends YourEvent {
  final String id;
  const GetEntityRequested(this.id);
  @override
  List<Object> get props => [id];
}

// your_state.dart
part of 'your_bloc.dart';

abstract class YourState extends Equatable {
  const YourState();
  @override
  List<Object> get props => [];
}

class YourInitial extends YourState {}
class YourLoading extends YourState {}
class YourLoaded extends YourState {
  final YourEntity entity;
  const YourLoaded(this.entity);
  @override
  List<Object> get props => [entity];
}
class YourError extends YourState {
  final String message;
  const YourError(this.message);
  @override
  List<Object> get props => [message];
}
```

**3. Create Page** (`presentation/pages/your_page.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_routes.dart';
import '../bloc/your_bloc.dart';

class YourPage extends StatelessWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<YourBloc>()..add(GetEntityRequested('1')),
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Feature')),
        body: BlocBuilder<YourBloc, YourState>(
          builder: (context, state) {
            if (state is YourLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is YourLoaded) {
              return Center(child: Text(state.entity.name));
            } else if (state is YourError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

### Step 5: Register in Dependency Injection

Add to `core/di/injection_container.dart`:

```dart
// Data Sources
getIt.registerLazySingleton<YourRemoteDataSource>(
  () => YourRemoteDataSourceImpl(getIt<HttpClientService>()),
);
getIt.registerLazySingleton<YourLocalDataSource>(
  () => YourLocalDataSourceImpl(
    hiveStorage: getIt<HiveStorageService>(),
    secureStorage: getIt<SecureStorageService>(),
  ),
);

// Repository
getIt.registerLazySingleton<YourRepository>(
  () => YourRepositoryImpl(
    remoteDataSource: getIt<YourRemoteDataSource>(),
    localDataSource: getIt<YourLocalDataSource>(),
  ),
);

// Use Cases
getIt.registerLazySingleton<GetEntityUseCase>(
  () => GetEntityUseCase(getIt<YourRepository>()),
);

// BLoC
getIt.registerFactory<YourBloc>(
  () => YourBloc(getEntityUseCase: getIt<GetEntityUseCase>()),
);
```

### Step 6: Add Route

Add to `core/router/app_routes.dart`:
```dart
static const String yourFeature = '/your-feature';
static const String yourFeatureName = 'your-feature';
```

Add to `core/router/app_router.dart`:
```dart
GoRoute(
  path: AppRoutes.yourFeature,
  name: AppRoutes.yourFeatureName,
  builder: (context, state) => const YourPage(),
),
```

### Step 7: Generate Code

Run build runner for JSON serialization:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎯 Key Principles

### 1. **Separation of Concerns**
Each layer has a single, well-defined responsibility.

### 2. **Dependency Inversion**
High-level modules don't depend on low-level modules. Both depend on abstractions.

### 3. **Single Responsibility**
Each class/function has one reason to change.

### 4. **Testability**
- Domain layer: Pure Dart, easy to test
- Data layer: Mock data sources
- Presentation layer: Mock use cases

## 🚨 Error Handling

### Exception to Failure Conversion

- **Exceptions**: Thrown in data layer (ServerException, CacheException, etc.)
- **Failures**: Returned in domain layer (ServerFailure, CacheFailure, etc.)
- **BaseRepository**: Converts exceptions to failures automatically

### Usage Pattern

All repositories use `BaseRepository` mixin which automatically converts exceptions to failures:

```dart
return handleException(() async {
  // Your code here
  // Exceptions are automatically converted to Failures
});
```

### Result Types

Use `ResultFuture<T>` for async operations:
```dart
ResultFuture<User> login(String email, String password);
```

Use in BLoC:
```dart
final result = await getUserUseCase(GetUserParams(id: '123'));
result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (user) => emit(SuccessState(user)),
);
```

## 🧪 Testing Strategy

### Unit Tests
- **Domain layer**: Test use cases with mocked repositories
- **Data layer**: Test repositories with mocked data sources
- **Presentation layer**: Test BLoCs with mocked use cases

### Widget Tests
- Test pages and widgets in isolation
- Mock BLoCs and use cases

### Integration Tests
- Test full feature flows
- Test navigation and user interactions

### Mocking
- Use interfaces for easy mocking
- Mock repositories in use case tests
- Mock use cases in BLoC tests

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `dartz`: Functional programming (Either type)
- `equatable`: Value equality
- `go_router`: Navigation
- `dio`: HTTP client
- `hive`: Local storage
- `flutter_secure_storage`: Secure storage

### Dev Dependencies
- `build_runner`: Code generation
- `json_serializable`: JSON serialization
- `flutter_lints`: Linting rules

## 🎨 Features

- ✅ Clean Architecture
- ✅ Feature-based structure
- ✅ State management with BLoC
- ✅ Dependency injection with GetIt
- ✅ Error handling with Either pattern
- ✅ Local storage with Hive
- ✅ Secure storage
- ✅ HTTP client with Dio
- ✅ Routing with GoRouter
- ✅ Internationalization support
- ✅ Theme support (Light/Dark/System)
- ✅ Network connectivity monitoring
- ✅ Biometric authentication
- ✅ Local notifications
- ✅ Firebase Messaging (optional)
- ✅ Responsive design support

## 📱 Responsive Design

The project uses the `responsive_framework` package for responsive design support across different screen sizes and orientations.

### Orientation Support

The app supports both **portrait** and **landscape** orientations on all devices. Layouts automatically adapt based on screen size and orientation.

### Breakpoints

The app defines the following breakpoints (configured in `main.dart`):
- **Mobile**: 0 - 450px
- **Tablet**: 451 - 800px
- **Desktop**: 801 - 1920px
- **4K**: 1921px and above

### Usage

Use the `AppResponsive` utility class for responsive design:

```dart
import 'package:cp/core/utils/responsive_utils.dart';

// Check screen type
final isMobile = AppResponsive.isMobile(context);
final isTablet = AppResponsive.isTablet(context);
final isDesktop = AppResponsive.isDesktop(context);

// Check orientation
final isLandscape = AppResponsive.isLandscape(context);
final isPortrait = AppResponsive.isPortrait(context);
final isCompact = AppResponsive.isCompactLayout(context);

// Get responsive values
final padding = AppResponsive.responsivePadding(
  context,
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
  desktop: EdgeInsets.all(32),
);

// Get orientation-aware padding
final paddingWithOrientation = AppResponsive.responsivePaddingWithOrientation(
  context,
  mobilePortrait: EdgeInsets.all(16),
  mobileLandscape: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  tabletPortrait: EdgeInsets.all(24),
  tabletLandscape: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
);

final fontSize = AppResponsive.responsiveFontSize(
  context,
  mobile: 16,
  tablet: 18,
  desktop: 20,
);

// Get responsive grid columns (with orientation support)
final columns = AppResponsive.responsiveGridColumns(
  context,
  mobile: 1,
  tablet: 2,
  desktop: 3,
  mobileLandscape: 2,  // More columns in landscape
  tabletLandscape: 3,  // More columns in landscape
  desktopLandscape: 4, // More columns in landscape
);
```

### Available Methods

#### Screen Type Detection
- `isMobile(BuildContext)` - Check if screen is mobile
- `isTablet(BuildContext)` - Check if screen is tablet
- `isDesktop(BuildContext)` - Check if screen is desktop
- `getBreakpoint(BuildContext)` - Get current breakpoint name

#### Orientation Detection
- `isLandscape(BuildContext)` - Check if landscape orientation
- `isPortrait(BuildContext)` - Check if portrait orientation
- `isCompactLayout(BuildContext)` - Check if device should use compact layout

#### Responsive Values
- `responsiveValue<T>(...)` - Get responsive value based on screen size
- `responsiveValueWithOrientation<T>(...)` - Get responsive value considering both screen size and orientation
- `responsivePadding(...)` - Get responsive padding
- `responsivePaddingWithOrientation(...)` - Get responsive padding that adapts to orientation
- `responsiveFontSize(...)` - Get responsive font size
- `responsiveGridColumns(...)` - Get responsive grid column count (with orientation support)
- `responsiveMaxWidth(...)` - Get responsive max width for content
- `responsiveSpacing(...)` - Get responsive spacing

#### Screen Dimensions
- `screenWidth(BuildContext)` - Get screen width
- `screenHeight(BuildContext)` - Get screen height
- `effectiveWidth(BuildContext)` - Get effective screen width
- `effectiveHeight(BuildContext)` - Get effective screen height

### Examples

#### Conditional Layout with Orientation Support
```dart
final isDesktop = AppResponsive.isDesktop(context);
final isTablet = AppResponsive.isTablet(context);
final isLandscape = AppResponsive.isLandscape(context);

// On desktop or tablet in landscape, use sidebar layout
if (isDesktop || (isTablet && isLandscape)) {
  return Row(
    children: [
      Sidebar(),
      Expanded(child: Content()),
    ],
  );
} else {
  // Mobile/Tablet in portrait, use tabs
  return TabBarView(...);
}
```

#### Responsive Grid with Orientation
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: AppResponsive.responsiveGridColumns(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      mobileLandscape: 2,  // 2 columns in landscape
      tabletLandscape: 3,  // 3 columns in landscape
      desktopLandscape: 4, // 4 columns in landscape
    ),
    childAspectRatio: AppResponsive.isLandscape(context) ? 1.5 : 1.2,
  ),
  itemBuilder: (context, index) => Item(),
)
```

#### Orientation-Aware Padding
```dart
Padding(
  padding: AppResponsive.responsivePaddingWithOrientation(
    context,
    mobilePortrait: EdgeInsets.all(16),
    mobileLandscape: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    tabletPortrait: EdgeInsets.all(24),
    tabletLandscape: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
  ),
  child: Content(),
)
```

#### Responsive Text
```dart
Text(
  'Hello',
  style: TextStyle(
    fontSize: AppResponsive.responsiveFontSize(
      context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ),
  ),
)
```

#### Compact Layout Detection
```dart
final isCompact = AppResponsive.isCompactLayout(context);

TabBar(
  tabs: [
    Tab(
      icon: Icon(Icons.home),
      text: isCompact ? null : 'Home', // Hide text in compact mode
    ),
  ],
)
```

## 📝 Code Generation

For JSON serialization and Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🛠️ Feature Generator Script

The project includes an automated feature generator script that creates a complete feature following Clean Architecture patterns.

### Usage

```bash
# Using Dart directly
dart run scripts/create_feature.dart <feature_name>

# Or using the bash wrapper
./scripts/create_feature.sh <feature_name>

# Examples
dart run scripts/create_feature.dart products
dart run scripts/create_feature.dart orders
dart run scripts/create_feature.dart user_profile
```

### What It Creates

The script automatically generates:

1. **Directory Structure**: All necessary folders for data, domain, and presentation layers
2. **Domain Layer**:
   - Entity class
   - Repository interface
   - Use cases (GetAll, GetById)
3. **Data Layer**:
   - Model with JSON serialization
   - Remote data source
   - Local data source
   - Repository implementation
4. **Presentation Layer**:
   - BLoC with events and states
   - Page widget
5. **Configuration Updates**:
   - Dependency injection setup
   - Router configuration
   - Route constants

### After Running the Script

1. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Customize the entity with your specific fields

3. Update API endpoints in the remote data source

4. Customize BLoC events and states as needed

5. Build your UI in the page widget

### Naming Conventions

The script automatically handles naming conventions:
- Feature name: `products` → Creates `ProductsEntity`, `ProductsRepository`, etc.
- Pluralization: `product` → `products`, `category` → `categories`
- File names: snake_case (e.g., `product_entity.dart`)
- Class names: PascalCase (e.g., `ProductEntity`)

## 🗑️ Remove Feature Script

To remove a feature from the project, use the remove feature script:

```bash
# Using Dart directly
dart run scripts/remove_feature.dart <feature_name>

# Or using the bash wrapper
./scripts/remove_feature.sh <feature_name>

# Examples
dart run scripts/remove_feature.dart products
dart run scripts/remove_feature.dart orders
```

### What It Removes

The script automatically removes:

1. **Feature Directory**: `lib/features/<feature_name>/` (entire directory tree)
2. **DI Container**: All imports and registrations for the feature
3. **Router**: Route import and route configuration
4. **Route Constants**: Route path and name constants from `app_routes.dart`

### Safety Features

- ✅ **Confirmation Required**: The script asks for confirmation before deleting (type "yes" or "y")
- ✅ **Existence Check**: Verifies the feature exists before attempting removal
- ✅ **Error Handling**: Provides clear error messages if something goes wrong
- ✅ **Cleanup**: Removes all references to the feature from configuration files

### After Running the Script

1. Run: `flutter pub get`
2. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Verify the app still compiles and runs correctly
4. Commit your changes

**⚠️ Warning**: The script will permanently delete the feature. Make sure you have committed any changes you want to keep before running it.

## 🤝 Contributing

1. Follow the Clean Architecture principles
2. Add features using the feature-based structure
3. Write tests for new features
4. Follow the existing code style
5. Update documentation as needed

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Clean Architecture by Robert C. Martin
- Flutter team for the amazing framework
- All the open-source contributors
