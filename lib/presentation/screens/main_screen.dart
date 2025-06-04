import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/routes.dart';
import '../features/books/screens/explore_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
// Import other screens as they are created

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of screens to be displayed in the body of the Scaffold
  static final List<Widget> _screens = <Widget>[
    // Link ExploreScreen to the Home tab
    const ExploreScreen(),
    // Link SearchScreen to the Search tab
    const SearchScreen(),
    // Link ExploreScreen to the Library tab (showing the book collection)
    const ExploreScreen(),
    // Link ProfileScreen to the Profile tab
    const ProfileScreen(),
  ];

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
          _getTitle(_selectedIndex),
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
      drawer: AppDrawer(currentRoute: _getCurrentRoute()),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* (open "add book" (or "favorite") */ },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Library';
      case 3:
        return 'Profile';
      default:
        return 'Book Companion';
    }
  }

  String _getCurrentRoute() {
    switch (_selectedIndex) {
      case 0:
        return '/';
      case 1:
        return '/search';
      case 2:
        return '/my-books';
      case 3:
        return '/profile';
      default:
        return '/';
    }
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