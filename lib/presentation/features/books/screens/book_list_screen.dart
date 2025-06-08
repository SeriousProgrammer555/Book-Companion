import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/app_scaffold.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../../../../widgets/empty_state.dart';
import '../models/book.dart';
import '../widgets/book_list_item.dart';

// Provider for fetching books
final booksProvider = FutureProvider<List<Book>>((ref) async {
  // TODO: Implement actual book fetching logic
  // For now, return an empty list
  return [];
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
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return AppScaffold(
      scaffoldKey: scaffoldKey,
      title: title,
      currentRoute: '/books',
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () => context.pushNamed('search'),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {
            // TODO: Show filter options
          },
        ),
      ],
      child: Container(
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
        child: booksAsync.when(
          data: (books) {
            final filteredBooks = books.where(filter).toList();
            if (filteredBooks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.all(24),
                  child: EmptyState(
                    title: emptyTitle,
                    message: emptyMessage,
                    icon: Icons.library_books,
                    actionLabel: 'Add Book',
                    onActionPressed: () => context.pushNamed('add_book'),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      if (book.id != null) {
                        context.goNamed(
                          'book_detail',
                          pathParameters: {'id': book.id!},
                        );
                      }
                    },
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(16),
                      child: BookListItem(book: book),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error?.toString() ?? 'An unknown error occurred',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(booksProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphicContainer(
      // This GlassmorphicContainer does not have an onTap property.
      // If you intended to make this card tappable, wrap its content with a GestureDetector.
      child: GestureDetector(
        onTap: () =>
            context.goNamed('book_detail', pathParameters: {'id': book.id ?? ''}),
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
              book.author ?? '', // Use '' (an empty string) if book.author is null
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
      ),
    );
  }
}