import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/books/${book.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: book.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(book.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: book.coverUrl == null
                    ? const Icon(Icons.book, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (book.author != null) ...[
                      Text(
                        book.author!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Reading progress
                    if (book.totalPages != null && book.currentPage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${(book.currentPage! / book.totalPages! * 100).toStringAsFixed(1)}%',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: book.currentPage! / book.totalPages!,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 