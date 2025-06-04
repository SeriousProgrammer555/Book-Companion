import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/di/app_module.dart';
import '../../../../data/models/book.dart';
import '../../../widgets/glassmorphic_container.dart';

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getAllBooks();
});

class BookListScreen extends ConsumerWidget {
  final String title;
  final bool Function(Book) filter;
  final String emptyTitle;
  final String emptyMessage;

  const BookListScreen({
    super.key,
    this.title = 'My Library',
    this.filter = _defaultFilter,
    this.emptyTitle = 'No Books Yet',
    this.emptyMessage = 'Start by adding your first book to your collection.',
  });

  static bool _defaultFilter(Book book) => true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.8),
              colorScheme.background,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Decorative elements
                      ...List.generate(3, (index) => Positioned(
                        right: -50 + (index * 100),
                        top: -50 + (index * 50),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      )),
                      // Book icons decoration
                      ...List.generate(5, (index) => Positioned(
                        right: 20 + (index * 40),
                        bottom: 20,
                        child: Icon(
                          Icons.auto_stories,
                          color: Colors.white.withOpacity(0.2),
                          size: 24,
                        ),
                      )),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => context.push('/search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      // TODO: Show filter options
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildBookCard(
                        context,
                        Book(
                          id: 'book_$index',
                          title: [
                            'Atomic Habits',
                            'How to Win Friends and Influence People',
                            'Think and Grow Rich',
                            'Rich Dad Poor Dad',
                            'The Forty Rules of Love',
                            'Harry Potter and the Philosopher\'s Stone',
                            'The Silence of the Lambs',
                            'Great Expectations',
                            'Pride and Prejudice'
                          ][index],
                          author: [
                            'James Clear',
                            'Dale Carnegie',
                            'Napoleon Hill',
                            'Robert Kiyosaki',
                            'Elif Shafak',
                            'JK Rowling',
                            'Thomas Harris',
                            'Charles Dickens',
                            'Jane Austen'
                          ][index],
                          coverUrl: 'https://picsum.photos/200/300?random=$index',
                          totalPages: 300,
                          status: 'want_to_read',
                          currentPage: 0,
                          startDate: DateTime.now(),
                          readingHistory: {},
                          highlights: [],
                          readingSessions: [],
                          bookmarks: [],
                          readingStreak: {},
                        ),
                      ).animate()
                          .fadeIn(delay: Duration(milliseconds: 100 * index))
                          .slideY(begin: 0.2, end: 0);
                    },
                    childCount: 9, // Updated to match the number of books
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/books/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        backgroundColor: colorScheme.secondary,
      ).animate()
          .fadeIn(delay: 500.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphicContainer(
      onTap: () => context.goNamed('book_detail', pathParameters: {'id': book.id}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    book.coverUrl ?? 'https://via.placeholder.com/200x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  // Reading progress overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.bookmark,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${book.currentPage}/${book.totalPages}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}