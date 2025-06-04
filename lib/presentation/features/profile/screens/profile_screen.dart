import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../../data/models/book.dart';
import '../../../../data/services/storage/firebase_service.dart';

final profileProvider = FutureProvider<List<Book>>((ref) async {
  final firebaseService = FirebaseService();
  return firebaseService.getAllBooks();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const List<Map<String, dynamic>> _achievements = [
    {
      'title': 'First Book',
      'description': 'Complete your first book',
      'icon': Icons.book,
      'threshold': 1,
      'color': Colors.blue,
      'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
      'xp': 100,
    },
    {
      'title': 'Bookworm',
      'description': 'Complete 5 books',
      'icon': Icons.auto_stories,
      'threshold': 5,
      'color': Colors.green,
      'gradient': [Color(0xFF4CAF50), Color(0xFF388E3C)],
      'xp': 500,
    },
    {
      'title': 'Bibliophile',
      'description': 'Complete 10 books',
      'icon': Icons.menu_book,
      'threshold': 10,
      'color': Colors.purple,
      'gradient': [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      'xp': 1000,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return booksAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (books) {
        final completedBooks = books.where((b) => b.status == 'completed').length;
        final readingBooks = books.where((b) => b.status == 'reading').length;
        final totalPages = books.fold<int>(0, (sum, book) => sum + (book.currentPage));

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                        ),
                      ),
                      // Decorative circles
                      ...List.generate(3, (index) => Positioned(
                        right: -50 + (index * 100),
                        top: -50 + (index * 50),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                      )),
                      // Profile content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Hero(
                                    tag: 'profile-avatar',
                                    child: GestureDetector(
                                      onTap: () {
                                        // TODO: Show profile edit dialog
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colorScheme.surface,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 40,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: colorScheme.surface,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Book Enthusiast',
                                                style: textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: colorScheme.onPrimaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Level ${(completedBooks / 5).floor() + 1}',
                                                    style: textTheme.labelMedium?.copyWith(
                                                      color: colorScheme.onPrimaryContainer,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Member since ${DateFormat('MMM yyyy').format(DateTime.now())}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onPrimary.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: (completedBooks % 5) / 5,
                                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.onPrimary,
                                          ),
                                          minHeight: 4,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${completedBooks % 5}/5 books to next level',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onPrimary.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickStat(
                                    context,
                                    completedBooks.toString(),
                                    'Completed',
                                    Icons.bookmark,
                                    colorScheme.primary,
                                  ),
                                  _buildQuickStat(
                                    context,
                                    readingBooks.toString(),
                                    'Reading',
                                    Icons.menu_book,
                                    colorScheme.secondary,
                                  ),
                                  _buildQuickStat(
                                    context,
                                    NumberFormat.compact().format(totalPages),
                                    'Pages',
                                    Icons.format_list_numbered,
                                    colorScheme.tertiary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Show notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAchievements(context, books),
                    const SizedBox(height: 24),
                    _buildReadingGoals(context, books),
                    const SizedBox(height: 24),
                    _buildSettings(context),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Add new book
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 3,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/books');
                  break;
                case 2:
                  context.go('/search');
                  break;
                case 3:
                  // Already on profile
                  break;
              }
            },
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
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context, List<Book> books) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final completedBooks = books.where((b) => b.status == 'completed').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Show all achievements
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ProfileScreen._achievements.map((achievement) {
          final index = ProfileScreen._achievements.indexOf(achievement);
          final threshold = achievement['threshold'] as int;
          final unlocked = completedBooks >= threshold;
          final gradient = achievement['gradient'] as List<Color>;

          return _buildAchievementCard(
            context,
            achievement['title'] as String,
            achievement['description'] as String,
            achievement['icon'] as IconData,
            unlocked,
            gradient[0],
            achievement['xp'] as int,
          );
        }),
      ],
    );
  }

  Widget _buildReadingGoals(BuildContext context, List<Book> books) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final completedBooks = books.where((b) => b.status == 'completed').length;
    const monthlyGoal = 5; // TODO: Make this configurable
    final progress = completedBooks / monthlyGoal;

    return GlassmorphicContainer(
      width: double.infinity,
      height: 180,
      borderRadius: 16,
      blur: 10,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Goal',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedBooks/$monthlyGoal books',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 12,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal Progress',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${monthlyGoal - completedBooks} books remaining',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphicContainer(
      width: double.infinity,
      height: 320,
      borderRadius: 16,
      blur: 10,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Settings',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.palette,
            title: 'App Theme',
            subtitle: 'Customize app appearance',
            onTap: () {
              // TODO: Navigate to theme settings
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage reading reminders',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Sync your reading data',
            onTap: () {
              // TODO: Navigate to backup settings
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and credits',
            onTap: () {
              // TODO: Navigate to about screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool unlocked,
    Color color,
    int xp,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final index = ProfileScreen._achievements.indexWhere((a) => a['title'] == title);
    final gradient = ProfileScreen._achievements[index]['gradient'] as List<Color>;

    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 16,
      blur: 10,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: unlocked ? () {
            // TODO: Show achievement details
          } : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: unlocked ? gradient : [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainerHighest.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: unlocked ? [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: unlocked ? Colors.white : colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: unlocked ? gradient[0] : colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: unlocked ? gradient[0].withOpacity(0.1) : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: unlocked ? gradient[0] : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+$xp XP',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: unlocked ? gradient[0] : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: unlocked ? gradient[0].withOpacity(0.1) : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    unlocked ? Icons.check_circle : Icons.lock_outline,
                    color: unlocked ? gradient[0] : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 