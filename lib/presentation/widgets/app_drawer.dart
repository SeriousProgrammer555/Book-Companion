import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth/auth_service.dart';
import '../../core/di/app_module.dart';

// Custom color constants
const Color kPrimaryBlue = Color(0xFF4A90E2);
const Color kDeepPurple = Color(0xFF7E57C2);
const Color kLightBlue = Color(0xFF64B5F6);
const Color kLightPurple = Color(0xFF9575CD);
const Color kWhite = Colors.white;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showHomeButton;
  final Color? backgroundColor;
  final double elevation;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showHomeButton = true,
    this.backgroundColor,
    this.elevation = 0,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.black),
              onPressed: () {
                if (scaffoldKey != null) {
                  scaffoldKey!.currentState?.openDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            ),
      actions: [
        if (showHomeButton)
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.black),
            onPressed: () => context.go('/'),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final authService = ref.read(authServiceProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryBlue, kDeepPurple],
          stops: [0.0, 1.0],
        ),
      ),
      child: NavigationDrawer(
        backgroundColor: Colors.transparent,
        selectedIndex: _getSelectedIndex(currentRoute),
        onDestinationSelected: (index) {
          Navigator.pop(context);
          _navigateToDestination(context, index, ref);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Text(
              'Book Companion',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: kWhite,
                fontSize: 24,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.home_outlined, color: kWhite),
            selectedIcon: Icon(Icons.home, color: kLightBlue),
            label: Text('Home', style: TextStyle(color: kWhite)),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.analytics_outlined, color: kWhite),
            selectedIcon: Icon(Icons.analytics, color: kLightBlue),
            label: Text('Reading Stats', style: TextStyle(color: kWhite)),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.book_outlined, color: kWhite),
            selectedIcon: Icon(Icons.book, color: kLightBlue),
            label: Text('My Books', style: TextStyle(color: kWhite)),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.format_quote_outlined, color: kWhite),
            selectedIcon: Icon(Icons.format_quote, color: kLightBlue),
            label: Text('Quotes', style: TextStyle(color: kWhite)),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.emoji_emotions_outlined, color: kWhite),
            selectedIcon: Icon(Icons.emoji_emotions, color: kLightBlue),
            label: Text('Mood Tracking', style: TextStyle(color: kWhite)),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.person_outline, color: kWhite),
            selectedIcon: Icon(Icons.person, color: kLightBlue),
            label: Text('Profile', style: TextStyle(color: kWhite)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kWhite.withOpacity(0.1), kWhite.withOpacity(0.3), kWhite.withOpacity(0.1)],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                    Future.microtask(() {
                      if (context.mounted) {
                        context.pushNamed('add_book');
                      }
                    });
                  },
                  icon: const Icon(Icons.add, color: kDeepPurple),
                  label: const Text('Add New Book', 
                    style: TextStyle(
                      color: kDeepPurple,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: kWhite,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (context.canPop()) {
                      context.pop();
                    }
                    await authService.logout();
                    if (context.mounted) {
                      context.goNamed('login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: kWhite),
                  label: const Text('Logout', 
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kWhite,
                    side: const BorderSide(color: kWhite, width: 1.5),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String currentRoute) {
    switch (currentRoute) {
      case '/':
        return 0;
      case '/reading-stats':
        return 1;
      case '/books':
        return 2;
      case '/quotes':
        return 3;
      case '/mood':
        return 4;
      case '/profile':
        return 5;
      default:
        return -1;
    }
  }

  void _navigateToDestination(BuildContext context, int index, WidgetRef ref) {
    // Get current route to prevent unnecessary navigation
    final currentLocation = GoRouterState.of(context).matchedLocation;
    String targetRoute;

    switch (index) {
      case 0:
        targetRoute = '/';
        break;
      case 1:
        targetRoute = '/reading-stats';
        break;
      case 2:
        targetRoute = '/books';
        break;
      case 3:
        // For quotes, we need a book ID
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a book to view its quotes')),
        );
        return;
      case 4:
        // For mood tracking, we need a book ID
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a book to track mood')),
        );
        return;
      case 5:
        targetRoute = '/profile';
        break;
      default:
        targetRoute = '/';
    }

    // Only navigate if the target route is different from current route
    if (currentLocation != targetRoute && context.mounted) {
      // Use GoRouter's built-in pop functionality to close the drawer
      if (context.canPop()) {
        context.pop();
      }
      
      // Navigate using GoRouter
      final routeName = switch (targetRoute) {
        '/' => 'dashboard',
        '/reading-stats' => 'reading_stats',
        '/books' => 'books',
        '/profile' => 'profile',
        _ => 'dashboard',
      };
      
      // Use Future.microtask to ensure navigation happens after the current frame
      Future.microtask(() {
        if (context.mounted) {
          context.goNamed(routeName);
        }
      });
    }
  }
}