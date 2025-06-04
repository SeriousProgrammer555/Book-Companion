import 'package:flutter/material.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../../../../data/models/book.dart';

class BookDetailModernScreen extends StatelessWidget {
  final Book book;
  const BookDetailModernScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Cover, Title, Author, Rating
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background image or fallback color
                  Positioned.fill(
                    child: book.coverUrl != null
                        ? Image.network(
                            book.coverUrl!,
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.multiply,
                            color: Colors.black.withOpacity(0.3),
                            errorBuilder: (context, error, stackTrace) => 
                              Container(color: colorScheme.surfaceContainerHighest),
                          )
                        : Container(color: colorScheme.surfaceContainerHighest),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colorScheme.surface.withOpacity(0.8),
                            colorScheme.surface,
                          ],
                          stops: const [0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Book Cover, Title, Author, Rating
                  Positioned(
                    left: 24,
                    bottom: 24,
                    right: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'book-cover-${book.id}',
                          child: Material(
                            elevation: 4,
                            shadowColor: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: book.coverUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(book.coverUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              child: book.coverUrl == null
                                  ? Icon(
                                      Icons.book,
                                      size: 60,
                                      color: colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  book.title,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  'by ${book.author}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (book.rating != null)
                                SmoothStarRating(
                                  rating: book.rating!,
                                  allowHalfRating: false,
                                  size: 20,
                                  filledIconData: Icons.star,
                                  halfFilledIconData: Icons.star_half,
                                  defaultIconData: Icons.star_border,
                                  starCount: 5,
                                  spacing: 2.0,
                                  color: colorScheme.tertiary,
                                  borderColor: colorScheme.tertiary,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No description available.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {}, // TODO: Implement update progress
                      icon: const Icon(Icons.bookmark_added),
                      label: const Text('Update Progress'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {}, // TODO: Implement view quotes
                      icon: const Icon(Icons.format_quote),
                      label: const Text('View Quotes'),
                    ),
                  ),
                ],
              ),
            ),
            // Reading Progress Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Progress',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: book.totalPages > 0 ? book.currentPage / book.totalPages : 0,
                      minHeight: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.currentPage} / ${book.totalPages} pages',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${((book.currentPage / (book.totalPages > 0 ? book.totalPages : 1)) * 100).toStringAsFixed(1)}%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Highlights Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Highlights',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.highlights.isEmpty)
                    Text(
                      'No highlights yet.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (book.highlights.isNotEmpty)
                    ...book.highlights.map((highlight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      highlight,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
            // Review Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.rating != null)
                    SmoothStarRating(
                      rating: book.rating!,
                      allowHalfRating: false,
                      size: 24,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      starCount: 5,
                      spacing: 2.0,
                      color: colorScheme.tertiary,
                      borderColor: colorScheme.tertiary,
                    ),
                  if (book.review != null && book.review!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        book.review!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  if (book.rating == null && (book.review == null || book.review!.isEmpty))
                    Text(
                      'No review yet.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 