import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth/auth_service.dart';

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

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showHomeButton = true,
    this.backgroundColor,
    this.elevation = 0,
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
          : null,
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

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authService = Provider.of<AuthService>(context, listen: false);

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
          _navigateToDestination(context, index);
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
                    Navigator.pop(context);
                    context.push('/books/add');
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
                    Navigator.pop(context);
                    await authService.logout();
                    if (context.mounted) {
                      context.go('/login');
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

  void _navigateToDestination(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer first
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/reading-stats');
        break;
      case 2:
        context.go('/books');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a book to view its quotes')),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a book to track mood')),
        );
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }
}