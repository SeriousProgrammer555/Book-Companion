import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../features/books/screens/explore_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../widgets/widgets.dart';
// Import other screens as they are created

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb && size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: colorScheme.primary,
        scrolledUnderElevation: 0,
        title: Text(
          'Book Companion',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 32),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: Show notifications
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Welcome to Book Companion!\nAdd or explore books to get started.',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/books/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  // (Sample "popular" books (or "top cards") data.)
  // final List<Map<String, dynamic>> popularBooks = [
  //   { "title": "Book 1", "author": "Author 1", "cover": "https://picsum.photos/200/300?random=1", "rating": 4.5 },
  //   { "title": "Book 2", "author": "Author 2", "cover": "https://picsum.photos/200/300?random=2", "rating": 4.0 },
  //   { "title": "Book 3", "author": "Author 3", "cover": "https://picsum.photos/200/300?random=3", "rating": 5.0 },
  //   // (Add more books as needed.)
  // ];

  // (Sample "flash sale" (or "books") data.)
  // final List<Map<String, dynamic>> flashSaleBooks = [
  //   { "title": "Flash Sale Book 1", "author": "Author A", "cover": "https://picsum.photos/200/300?random=4", "price": 9.99 },
  //   { "title": "Flash Sale Book 2", "author": "Author B", "cover": "https://picsum.photos/200/300?random=5", "price": 12.99 },
  //   { "title": "Flash Sale Book 3", "author": "Author C", "cover": "https://picsum.photos/200/300?random=6", "price": 7.99 },
  //   // (Add more "flash sale" books as needed.)
  // ];
} 