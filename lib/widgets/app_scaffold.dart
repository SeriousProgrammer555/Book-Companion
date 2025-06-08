import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/widgets/app_drawer.dart';

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
      appBar: CustomAppBar(
        title: title ?? 'Book Companion',
        actions: actions,
        showBackButton: showBackButton,
        scaffoldKey: scaffoldKey,
      ),
      drawer: AppDrawer(currentRoute: currentRoute ?? '/'),
      body: child,
      floatingActionButton: shouldShowFab ? FloatingActionButton.extended(
        onPressed: () => context.go('/books/pdf-management'),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('PDF Management'),
      ) : null,
    );
  }
} 