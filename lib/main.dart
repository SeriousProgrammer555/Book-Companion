import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/config/app_config.dart';
import 'core/error/app_error.dart';
import 'core/routes.dart';
import 'core/theme.dart' as app_theme;
import 'data/services/auth/auth_service.dart';
import 'data/services/storage/firebase_service.dart';
import 'firebase_options.dart';


Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable offline persistence for Realtime Database
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    if (kIsWeb) {
      // Configure Firebase Auth persistence for web
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    AppConfig.logger.i('Firebase initialized successfully');
  } catch (e, stack) {
    AppConfig.logger.e('Failed to initialize Firebase', error: e, stackTrace: stack);
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await initializeFirebase();

    // Initialize app configuration
    await AppConfig.initialize();

    // Initialize connectivity monitoring
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      AppConfig.logger.i('Connectivity changed: $result');
    });

    runApp(
      ProviderScope(
        child: provider.MultiProvider(
          providers: [
            provider.Provider<AuthService>(
              create: (_) => AuthService(
                auth: FirebaseAuth.instance,
                database: FirebaseDatabase.instance,
              ),
            ),
            provider.Provider<FirebaseService>(
              create: (_) => FirebaseService(),
            ),
          ],
          child: const BookCompanionApp(),
        ),
      ),
    );
  } catch (error, stackTrace) {
    AppConfig.logger.e('Failed to initialize app', error: error, stackTrace: stackTrace);
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ErrorView(
            error: AppError.fromException(error, stackTrace),
            onRetry: () => main(),
          ),
        ),
      ),
    );
  }
}

class BookCompanionApp extends ConsumerWidget {
  const BookCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorProvider);
    final themeMode = ref.watch(themeProvider);

    if (error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: app_theme.AppTheme.lightTheme,
        darkTheme: app_theme.AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: ErrorView(
            error: error,
            onRetry: () => ref.read(errorProvider.notifier).clearError(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: app_theme.AppTheme.lightTheme,
      darkTheme: app_theme.AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(AppConfig.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppConfig.setDarkMode(state == ThemeMode.dark);
  }
}