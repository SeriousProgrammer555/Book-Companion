import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/di/app_module.dart';
import '../core/di/app_module.dart' as app_error;
import '../core/routes.dart';
import '../core/theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool showFloatingActionButton;
  final String? currentRoute;

  const AppScaffold({
    super.key,
    required this.child,
    this.showFloatingActionButton = true,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show FAB on PDF management screen to avoid duplicate buttons
    final shouldShowFab = showFloatingActionButton && currentRoute != '/books/pdf-management';

    return Scaffold(
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
    
    // Show loading indicator while initializing
    if (!isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    // Watch for errors
    ref.listen(app_error.errorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return MaterialApp.router(
      title: 'Book Companion',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        
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