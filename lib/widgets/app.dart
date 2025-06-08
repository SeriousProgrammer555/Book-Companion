import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/di/app_module.dart';
import '../core/routes.dart';
import '../core/theme/app_theme.dart';
// Corrected import: Go up one directory (from lib/widgets to lib),
// then down into presentation/widgets/app_drawer.dart
import '../presentation/widgets/app_drawer.dart'; // <--- CORRECTED IMPORT

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool showFloatingActionButton;
  final String? currentRoute;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppScaffold({
    super.key,
    required this.child,
    this.showFloatingActionButton = true,
    this.currentRoute,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show FAB on PDF management screen to avoid duplicate buttons
    final shouldShowFab = showFloatingActionButton && currentRoute != '/books/pdf-management';

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar( // Now recognized because app_drawer.dart is imported
        title: title ?? 'Book Companion',
        actions: actions,
        showBackButton: showBackButton,
        scaffoldKey: scaffoldKey,
      ),
      drawer: AppDrawer(currentRoute: currentRoute ?? '/'), // Now recognized
      body: child,
      floatingActionButton: shouldShowFab ? FloatingActionButton.extended(
        onPressed: () => context.go('/books/pdf-management'),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('PDF Management'),
      ) : null,
    );
  }
}

class BookCompanionApp extends ConsumerWidget {
  const BookCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for app initialization
    final isInitialized = ref.watch(appInitializedProvider);
    final router = ref.watch(routerProvider);

    // Show loading indicator while initializing
    if (!isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF7E57C2)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Book Companion',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) {
          return const Scaffold(
            body: Center(
              child: Text('Loading...'),
            ),
          );
        }

        // Get current route
        final currentRoute = GoRouterState.of(context).matchedLocation;

        // Wrap the child with AppScaffold
        return AppScaffold(
          currentRoute: currentRoute,
          child: child,
        );
      },
    );
  }
}