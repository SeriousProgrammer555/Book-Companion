import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/config/app_config.dart';
import 'core/error/app_error.dart';
import 'core/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/app_module.dart';
import 'firebase_options.dart';

// Create a provider to manage connectivity
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  final controller = StreamController<ConnectivityResult>();

  // Helper function to handle connectivity result
  Future<void> checkAndEmitConnectivity() async {
    try {
      final List<ConnectivityResult> results = await connectivity.checkConnectivity();
      if (!controller.isClosed) {
        // Ensure we handle the list result from checkConnectivity()
        if (results.isNotEmpty) {
          controller.add(results.first);
        } else {
          controller.add(ConnectivityResult.none);
        }
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      if (!controller.isClosed) {
        controller.add(ConnectivityResult.none);
      }
    }
  }

  // Check initial connectivity
  checkAndEmitConnectivity();

  // Set up periodic check
  final timer = Timer.periodic(
    const Duration(seconds: 1),
        (_) => checkAndEmitConnectivity(),
  );

  // Clean up
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a ProviderContainer to manage state during initialization
  final container = ProviderContainer();
  
  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set persistence based on platform
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } else {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }

    // Initialize app config
    await AppConfig.initialize();
    
    // Pass the container directly to initializeDependencies
    await initializeDependencies(container);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const BookCompanionApp(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    // Set initialization flag to false in case of error
    container.read(appInitializedProvider.notifier).state = false;
    
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const BookCompanionApp(),
      ),
    );
  }
}

class BookCompanionApp extends ConsumerWidget {
  const BookCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Watch for connectivity changes
    ref.listen<AsyncValue<ConnectivityResult>>(
      connectivityProvider,
      (_, next) => next.whenData((connectivity) {
        AppConfig.logger.i('Connectivity changed: $connectivity');
      }),
    );

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: AppConfig.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}