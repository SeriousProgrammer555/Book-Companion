import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/auth/auth_service.dart';
import '../presentation/features/admin/screens/admin_dashboard_screen.dart';
import '../presentation/features/auth/screens/login_screen.dart';
import '../presentation/features/auth/screens/register_screen.dart';
import '../presentation/features/books/screens/add_book_screen.dart';
import '../presentation/features/books/screens/book_detail_screen.dart';
import '../presentation/features/books/screens/book_list_screen.dart';
import '../presentation/features/books/screens/explore_screen.dart';
import '../presentation/features/books/screens/mood_tracking_screen.dart';
import '../presentation/features/books/screens/quotes_screen.dart';
import '../presentation/features/profile/screens/dashboard_screen.dart';
import '../presentation/features/profile/screens/profile_screen.dart';
import '../presentation/features/search/screens/search_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// List of routes that don't require authentication
const List<String> _publicRoutes = ['/login', '/register'];

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthService authService = Provider.of<AuthService>(context, listen: false);
      final bool isAuthenticated = authService.currentUser != null;
      final bool isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      // If the user is not authenticated and trying to access a protected route,
      // redirect to login
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // If the user is authenticated and trying to access login/register,
      // redirect to dashboard
      if (isAuthenticated && isPublicRoute) {
        return '/';
      }

      // If the user is not authenticated and trying to access a public route,
      // or if the user is authenticated and trying to access a protected route,
      // allow the navigation
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Shell route for main app navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Books
          GoRoute(
            path: '/books',
            name: 'books',
            builder: (context, state) => BookListScreen(
              title: 'My Books',
              filter: (book) => true,
              emptyTitle: 'No Books Yet',
              emptyMessage: 'Start by adding your first book to your collection.',
            ),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add_book',
                builder: (context, state) => const AddBookScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'book_detail',
                builder: (context, state) {
                  final String? bookId = state.pathParameters['id'];
                  if (bookId == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text('Book ID is required'),
                      ),
                    );
                  }
                  return BookDetailScreen(bookId: bookId);
                },
              ),
            ],
          ),

          // Completed Books
          GoRoute(
            path: '/completed',
            name: 'completed',
            builder: (context, state) => BookListScreen(
              title: 'Completed Books',
              filter: (book) => book.status == 'completed',
              emptyTitle: 'No Completed Books',
              emptyMessage: 'You haven\'t completed any books yet.',
            ),
          ),

          // Search
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),

          // Explore
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),

          // Quotes
          GoRoute(
            path: '/quotes',
            name: 'quotes',
            builder: (context, state) {
              final String? bookId = state.uri.queryParameters['bookId'];
              if (bookId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Please select a book to view quotes'),
                  ),
                );
              }
              return QuotesScreen(bookId: bookId);
            },
          ),

          // Mood Tracking
          GoRoute(
            path: '/mood',
            name: 'mood',
            builder: (context, state) {
              final String? bookId = state.uri.queryParameters['bookId'];
              if (bookId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Please select a book to track mood'),
                  ),
                );
              }
              return MoodTrackingScreen(bookId: bookId);
            },
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Admin
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri.path}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed('dashboard');
              break;
            case 1:
              context.goNamed('books');
              break;
            case 2:
              context.goNamed('search');
              break;
            case 3:
              context.goNamed('profile');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/books')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // Dashboard
  }
}

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authService = Provider.of<AuthService>(context, listen: false);

    return NavigationDrawer(
      selectedIndex: _getSelectedIndex(currentRoute),
      onDestinationSelected: (index) {
        Navigator.pop(context); // Close drawer
        _navigateToDestination(context, index);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Text(
            'Book Companion',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text('Explore'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text('My Books'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.format_quote_outlined),
          selectedIcon: Icon(Icons.format_quote),
          label: Text('Quotes'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.emoji_emotions_outlined),
          selectedIcon: Icon(Icons.emoji_emotions),
          label: Text('Mood Tracking'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FilledButton.icon(
                onPressed: () => context.push('/books/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add New Book'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await authService.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getSelectedIndex(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/explore':
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
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/books');
        break;
      case 3:
      // For quotes, we should navigate from the book detail screen instead
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a book to view its quotes'),
          ),
        );
        break;
      case 4:
      // For mood tracking, we should navigate from the book detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a book to track mood'),
          ),
        );
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }
}
