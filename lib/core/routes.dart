import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../presentation/features/reading_stats/screens/reading_stats_screen.dart';
import '../core/di/app_module.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// List of routes that don't require authentication
final _publicRoutes = [
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
];

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true, // Keep debug logging enabled
    redirect: (context, state) {
      final isLoggedIn = authService.isLoggedIn;
      final isInitialized = ref.read(appInitializedProvider);

      // Show loading screen while not initialized
      if (!isInitialized) {
        return null;
      }

      // Check if the requested route is a public route
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      // If logged in and trying to access public route, redirect to home
      if (isLoggedIn && isPublicRoute) {
        return '/';
      }

      // If not logged in and trying to access protected route, redirect to login
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Allow the navigation to proceed
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Page not found: ${state.uri.path}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
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

      // Main app routes
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/books',
        name: 'books',
        builder: (context, state) => const BookListScreen(
          title: 'My Books',
          emptyTitle: 'No Books Yet',
          emptyMessage: 'Start by adding your first book to your collection.',
        ),
      ),
      GoRoute(
        path: '/books/add',
        name: 'add_book',
        builder: (context, state) => const AddBookScreen(),
      ),
      GoRoute(
        path: '/books/:id',
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
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const ExploreScreen(),
      ),
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
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/reading-stats',
        name: 'reading_stats',
        builder: (context, state) => const ReadingStatsScreen(),
      ),
    ],
  );
});
