// lib/core/monitoring/crash_monitoring_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CrashMonitoringService {
  static Future<void> initialize() async {
    // Dual monitoring with Firebase and Sentry
    await SentryFlutter.init(
      (options) {
        options.dsn = 'YOUR_SENTRY_DSN';
        options.tracesSampleRate = 1.0;
        options.enableAutoSessionTracking = true;
      },
      appRunner: () => runApp(const MyApp()),
    );

    // Configure Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  static void recordError(dynamic exception, StackTrace? stack) {
    // Log to both monitoring services
    FirebaseCrashlytics.instance.recordError(exception, stack);
    Sentry.captureException(exception, stackTrace: stack);
  }
}

// lib/core/monitoring/performance_monitoring.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitoringService {
  static Future<void> initialize() async {
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  static HttpMetric createHttpMetric(String url, HttpMethod method) {
    return FirebasePerformance.instance.newHttpMetric(url, method);
  }
}

// lib/core/disaster_recovery/app_backup_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppBackupService {
  static Future<void> createFullBackup() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDocDir.path}/backups');
    
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }

    // Backup secure storage
    final secureStorage = FlutterSecureStorage();
    final allValues = await secureStorage.readAll();
    
    // Backup local file storage
    await _backupLocalFiles(backupDir.path);
    
    // Create backup manifest
    final backupManifest = {
      'timestamp': DateTime.now().toIso8601String(),
      'secureStorageKeys': allValues.keys.toList(),
    };

    // Write manifest
    final manifestFile = File('${backupDir.path}/backup_manifest.json');
    await manifestFile.writeAsString(jsonEncode(backupManifest));
  }

  static Future<void> _backupLocalFiles(String backupPath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final sourceDir = appDocDir.path;
    
    // Copy all application documents
    await Directory(sourceDir)
      .list(recursive: true)
      .where((entity) => entity is File)
      .forEach((entity) async {
        final file = entity as File;
        final relativePath = file.path.replaceFirst(sourceDir, '');
        final backupFile = File('$backupPath$relativePath');
        
        // Ensure backup directory exists
        await backupFile.parent.create(recursive: true);
        
        // Copy file
        await file.copy(backupFile.path);
      });
  }
}

// lib/core/disaster_recovery/app_recovery_service.dart
class AppRecoveryService {
  static Future<bool> recoverFromLatestBackup() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDocDir.path}/backups');
    
    if (!backupDir.existsSync()) {
      return false;
    }

    // Find latest backup
    final backupManifests = backupDir
      .listSync()
      .where((file) => file.path.endsWith('backup_manifest.json'))
      .toList();
    
    if (backupManifests.isEmpty) {
      return false;
    }

    // Sort and get latest backup
    backupManifests.sort((a, b) => 
      File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync())
    );

    final latestManifestFile = File(backupManifests.first.path);
    final manifestContent = await latestManifestFile.readAsString();
    final manifest = jsonDecode(manifestContent);

    // Restore secure storage
    final secureStorage = FlutterSecureStorage();
    for (var key in manifest['secureStorageKeys']) {
      final value = await secureStorage.read(key: key);
      if (value != null) {
        await secureStorage.write(key: key, value: value);
      }
    }

    return true;
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize monitoring services
  await CrashMonitoringService.initialize();
  await PerformanceMonitoringService.initialize();

  // Periodic backup strategy
  Timer.periodic(Duration(days: 1), (_) {
    AppBackupService.createFullBackup();
  });

  runApp(const MyApp());
}
