import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../widgets/widgets.dart';
import '../providers/dashboard_provider.dart';

class PopularBook {
  final String title;
  final String author;
  final String imageUrl;

  PopularBook({
    required this.title,
    required this.author,
    required this.imageUrl,
  });
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  final List<PopularBook> popularBooks = [
    PopularBook(
      title: 'Atomic Habits',
      author: 'James Clear',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/81wgcld4wxL.jpg',
    ),
    PopularBook(
      title: 'Think and Grow Rich',
      author: 'Napoleon Hill',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/71UypkUjStL.jpg',
    ),
    PopularBook(
      title: 'The Silence of the Lambs',
      author: 'Thomas Harris',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/en/6/62/Silence3.png',
    ),
    PopularBook(
      title: 'Forty Rules of Love',
      author: 'Elif Shafak',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1442161289i/6642715.jpg',
    ),
    PopularBook(
      title: 'Rich Dad Poor Dad',
      author: 'Robert Kiyosaki',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/81bsw6fnUiL.jpg',
    ),
    PopularBook(
      title: 'The 7 Habits of Highly Effective People',
      author: 'Stephen Covey',
      imageUrl: 'https://thestationers.pk/cdn/shop/files/the-seven-habits-of-highly-effective-people-by-stephen-covey-the-stationers-1.jpg?v=1708446606',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isScrolled
            ? colorScheme.primary.withOpacity(0.95)
            : Colors.transparent,
        title: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'My Reading Journey',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18 / textScaleFactor,
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: _isScrolled ? colorScheme.onPrimary : Colors.white,
                size: isSmallScreen ? 24 : 28),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: _isScrolled ? colorScheme.onPrimary : Colors.white,
                size: isSmallScreen ? 24 : 28),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.background,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Welcome Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 28 : 32,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Start your reading journey',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0, delay: 100.ms),
                    ],
                  ),
                ),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
                  child: _buildReadingStatsHeader(context, state),
                ),
              ),

              // Popular Books Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Books',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 20 : 24,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: isSmallScreen ? 200 : 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: popularBooks.length,
                          itemBuilder: (context, index) {
                            final book = popularBooks[index];
                            return Container(
                              width: isSmallScreen ? 130 : 160,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          book.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: colorScheme.primaryContainer,
                                              child: Icon(
                                                Icons.book,
                                                size: 40,
                                                color: colorScheme.onPrimaryContainer,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.title,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    book.author,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: 200 * index));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: size.height * 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingStatsHeader(BuildContext context, dynamic state) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: _buildStatItem(
              context,
              '${state.currentStreak}',
              'Day Streak',
              Icons.local_fire_department,
              Colors.orange,
            ),
          ),
          Flexible(
            child: _buildStatItem(
              context,
              '${state.completedBooks.length}',
              'Books Read',
              Icons.menu_book,
              Colors.blue,
            ),
          ),
          Flexible(
            child: _buildStatItem(
              context,
              '${state.dailyProgress}',
              'Min Today',
              Icons.timer,
              Colors.green,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 200.ms);
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 22,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: isSmallScreen ? 10 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
