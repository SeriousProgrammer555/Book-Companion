import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../data/models/book.dart';
import '../glassmorphic_container.dart';


class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const BookListItem({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb && size.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final coverSize = isWeb ? 80.0 : 60.0;
        final fontSize = isWeb ? 16.0 : 14.0;
        final titleFontSize = isWeb ? 18.0 : 16.0;
        final padding = isWeb ? 20.0 : 16.0;

        double progress = book.totalPages > 0 
            ? (book.currentPage / book.totalPages).clamp(0.0, 1.0) 
            : 0.0;

        Color statusColor = theme.colorScheme.outline;
        if (book.status == 'reading') {
          statusColor = theme.colorScheme.primary;
        } else if (book.status == 'completed') {
          statusColor = theme.colorScheme.tertiary;
        } else if (book.status == 'want_to_read') {
          statusColor = theme.colorScheme.secondary;
        }

        return GlassmorphicContainer(
          height: isWeb ? 120 : 100,
          borderRadius: 16,
          blurRadius: 10,
          borderWidth: 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    // Book cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: coverSize,
                        height: coverSize * 1.5,
                        child: book.coverUrl != null
                            ? Image.network(
                                book.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.book,
                                    size: coverSize * 0.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.book,
                                  size: coverSize * 0.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Book details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              book.title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              book.author,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${book.currentPage}/${book.totalPages} pages',
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onFavoriteToggle != null)
                      IconButton(
                        icon: Icon(
                          book.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: book.isFavorite ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 