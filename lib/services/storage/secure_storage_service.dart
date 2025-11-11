import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;
import '../../core/utils/app_logger.dart';
import 'hive_storage_service.dart';

/// Service for secure storage with fallback to Hive on macOS development
///
/// On macOS, secure storage requires code signing for keychain access.
/// In development, we fall back to Hive storage when secure storage fails.
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final HiveStorageService? _fallbackStorage;
  bool?
  _secureStorageAvailable; // null = not tested yet, true = available, false = unavailable

  SecureStorageService(this._storage, {HiveStorageService? fallbackStorage})
    : _fallbackStorage = fallbackStorage;

  // Get a value
  Future<String?> get(String key) async {
    final fallbackStorage = _fallbackStorage;

    // On macOS, prioritize fallback storage since secure storage likely won't work
    if (Platform.isMacOS && fallbackStorage != null) {
      // If secure storage is known to be unavailable, use fallback directly
      if (_secureStorageAvailable == false) {
        final value = fallbackStorage.get<String>(_getFallbackKey(key));
        if (value != null) {
          AppLogger.d('Value retrieved from fallback storage: $key');
          return value;
        }
        return null;
      }

      // If we haven't tested secure storage yet, check fallback first
      // This ensures we read from fallback (where values are saved on macOS)
      if (_secureStorageAvailable == null) {
        // Check fallback first (where values are actually stored on macOS)
        final fallbackValue = fallbackStorage.get<String>(_getFallbackKey(key));
        if (fallbackValue != null) {
          AppLogger.d('Value found in fallback storage (macOS): $key');
          // Test secure storage in background to set availability flag
          _testSecureStorageAvailability();
          return fallbackValue;
        }
        // No value in fallback, test secure storage (it will likely fail on macOS)
        await _testSecureStorageAvailability();
        // After testing, if secure storage is available, try reading from it
        if (_secureStorageAvailable == true) {
          try {
            return await _storage.read(key: key);
          } catch (e) {
            AppLogger.w('Secure storage read failed after test: $e');
            _secureStorageAvailable = false;
          }
        }
        return null;
      }
    }

    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        final value = await _storage.read(key: key);
        // If we get a value from secure storage, mark it as available and return
        if (value != null) {
          _secureStorageAvailable = true;
          return value;
        }
        // If secure storage returns null, the key doesn't exist there
        // Check fallback storage for the value
        if (fallbackStorage != null) {
          final fallbackValue = fallbackStorage.get<String>(
            _getFallbackKey(key),
          );
          if (fallbackValue != null) {
            AppLogger.d('Value found in fallback storage: $key');
            return fallbackValue;
          }
        }
        return null;
      } catch (e) {
        // Secure storage failed
        if (Platform.isMacOS) {
          AppLogger.w(
            'Secure storage read failed on macOS, using fallback: $e',
          );
          _secureStorageAvailable = false;
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Use fallback storage (Hive) if secure storage is unavailable
    if (fallbackStorage != null) {
      try {
        final value = fallbackStorage.get<String>(_getFallbackKey(key));
        if (value != null) {
          AppLogger.d('Value retrieved from fallback storage: $key');
        }
        return value;
      } catch (e) {
        AppLogger.w('Fallback storage read failed: $e');
        return null;
      }
    }

    return null;
  }

  // Test if secure storage is available (doesn't throw exceptions)
  Future<void> _testSecureStorageAvailability() async {
    if (_secureStorageAvailable != null) {
      return; // Already tested
    }

    try {
      // Try to read a non-existent key to test if secure storage works
      // This will either return null (works) or throw an exception (doesn't work)
      await _storage.read(key: '__test_key_that_does_not_exist__');
      _secureStorageAvailable = true;
      AppLogger.d('Secure storage is available');
    } catch (e) {
      if (Platform.isMacOS) {
        AppLogger.w('Secure storage test failed on macOS: $e');
        _secureStorageAvailable = false;
      } else {
        // On other platforms, if secure storage throws, it's an error
        AppLogger.e('Secure storage test failed: $e');
        _secureStorageAvailable = false;
      }
    }
  }

  // Set a value
  Future<void> set(String key, String value) async {
    final fallbackStorage = _fallbackStorage;

    // On macOS, if secure storage is known to be unavailable, use fallback directly
    if (Platform.isMacOS &&
        _secureStorageAvailable == false &&
        fallbackStorage != null) {
      await fallbackStorage.set<String>(_getFallbackKey(key), value);
      AppLogger.d('Value saved to fallback storage: $key');
      return;
    }

    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        await _storage.write(key: key, value: value);
        _secureStorageAvailable = true;
        return;
      } catch (e) {
        // On macOS, secure storage might fail in development without code signing
        if (Platform.isMacOS) {
          AppLogger.w(
            'Secure storage write failed on macOS, using fallback: $e',
          );
          _secureStorageAvailable = false;
          // Fall through to fallback storage
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Use fallback storage (Hive) if secure storage is unavailable
    if (fallbackStorage != null) {
      try {
        await fallbackStorage.set<String>(_getFallbackKey(key), value);
        AppLogger.d('Value saved to fallback storage: $key');
      } catch (e) {
        AppLogger.e('Fallback storage write failed: $e');
        rethrow;
      }
    } else {
      throw Exception(
        'Secure storage unavailable and no fallback storage provided',
      );
    }
  }

  // Delete a value
  Future<void> delete(String key) async {
    final fallbackStorage = _fallbackStorage;

    // On macOS, if secure storage is known to be unavailable, use fallback directly
    if (Platform.isMacOS &&
        _secureStorageAvailable == false &&
        fallbackStorage != null) {
      await fallbackStorage.delete(_getFallbackKey(key));
      return;
    }

    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        await _storage.delete(key: key);
        _secureStorageAvailable = true;
        return;
      } catch (e) {
        if (Platform.isMacOS) {
          AppLogger.w(
            'Secure storage delete failed on macOS, using fallback: $e',
          );
          _secureStorageAvailable = false;
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Use fallback storage if secure storage is unavailable
    if (fallbackStorage != null) {
      try {
        await fallbackStorage.delete(_getFallbackKey(key));
      } catch (e) {
        AppLogger.w('Fallback storage delete failed: $e');
      }
    }
  }

  // Delete all values
  Future<void> deleteAll() async {
    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        await _storage.deleteAll();
        _secureStorageAvailable = true;
        return;
      } catch (e) {
        if (Platform.isMacOS) {
          AppLogger.w('Secure storage deleteAll failed on macOS: $e');
          _secureStorageAvailable = false;
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Note: We can't delete all fallback keys easily, so we skip this for fallback
    AppLogger.w('deleteAll not supported for fallback storage');
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final fallbackStorage = _fallbackStorage;

    // On macOS, if secure storage is known to be unavailable, use fallback directly
    if (Platform.isMacOS &&
        _secureStorageAvailable == false &&
        fallbackStorage != null) {
      final value = fallbackStorage.get<String>(_getFallbackKey(key));
      return value != null;
    }

    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        final exists = await _storage.containsKey(key: key);
        _secureStorageAvailable = true;
        return exists;
      } catch (e) {
        if (Platform.isMacOS) {
          AppLogger.w(
            'Secure storage containsKey failed on macOS, using fallback: $e',
          );
          _secureStorageAvailable = false;
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Use fallback storage if secure storage is unavailable
    if (fallbackStorage != null) {
      try {
        final value = fallbackStorage.get<String>(_getFallbackKey(key));
        return value != null;
      } catch (e) {
        AppLogger.w('Fallback storage containsKey failed: $e');
        return false;
      }
    }

    return false;
  }

  // Get all keys
  Future<Map<String, String>> readAll() async {
    // Try secure storage first (if available or not tested yet)
    if (_secureStorageAvailable != false) {
      try {
        final result = await _storage.readAll();
        _secureStorageAvailable = true;
        return result;
      } catch (e) {
        if (Platform.isMacOS) {
          AppLogger.w('Secure storage readAll failed on macOS: $e');
          _secureStorageAvailable = false;
        } else {
          _secureStorageAvailable = false;
          rethrow;
        }
      }
    }

    // Note: We can't easily get all keys from fallback storage
    AppLogger.w('readAll not fully supported for fallback storage');
    return {};
  }

  // Get fallback key with prefix to avoid conflicts
  String _getFallbackKey(String key) {
    return 'secure_storage_fallback_$key';
  }
}
