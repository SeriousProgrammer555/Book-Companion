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
import '../presentation/features/reading_stats/screens/reading_stats_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// List of routes that don't require authentication
const List<String> _publicRoutes = ['/login', '/register'];

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = auth.isLoggedIn;

      // Allow access to public routes
      if (_publicRoutes.contains(state.matchedLocation)) {
        return isLoggedIn ? '/' : null;
      }

      // Redirect to login if not logged in
      if (!isLoggedIn) {
        return '/login';
      }

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

      // Main app routes
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
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
        builder: (context, state) => const ReadingStatsScreen(),
      ),
    ],
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
