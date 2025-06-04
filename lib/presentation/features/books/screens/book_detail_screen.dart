import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../data/models/book.dart';
// import '../../../../data/models/reading_session.dart';
import '../../../../data/services/storage/firebase_service.dart';
import '../../../widgets/glassmorphic_container.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _goalController = TextEditingController();
  final _reviewController = TextEditingController();
  final _highlightController = TextEditingController();
  double? _rating;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _reviewController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  Future<void> _updateReadingProgress(Book book, int newPage) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final updatedHistory = Map<String, int>.from(book.readingHistory);
      updatedHistory[today] = (updatedHistory[today] ?? 0) + (newPage - book.currentPage);

      final updatedBook = book.copyWith(
        currentPage: newPage,
        lastReadDate: DateTime.now(),
        readingHistory: updatedHistory,
        status: newPage >= book.totalPages ? 'completed' : 'reading',
        finishDate: newPage >= book.totalPages ? DateTime.now() : null,
      );

      await FirebaseService().updateBook(updatedBook);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading progress updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating progress: $e')),
        );
      }
    }
  }

  Future<void> _updateDailyGoal(Book book) async {
    try {
      final goal = int.tryParse(_goalController.text);
      if (goal == null || goal <= 0) {
        throw Exception('Please enter a valid daily goal');
      }

      final updatedBook = book.copyWith(dailyGoal: goal);
      await FirebaseService().updateBook(updatedBook);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily goal updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updateReview(Book book, {
    required String review,
    required double? rating,
  }) async {
    try {
      final updatedBook = book.copyWith(
        review: review.trim(),
        rating: rating,
      );
      await FirebaseService().updateBook(updatedBook);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _addHighlight(Book book) async {
    final highlight = _highlightController.text.trim();
    if (highlight.isEmpty) return;

    try {
      final updatedHighlights = List<String>.from(book.highlights)..add(highlight);
      final updatedBook = book.copyWith(highlights: updatedHighlights);
      await FirebaseService().updateBook(updatedBook);

      if (mounted) {
        _highlightController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlight added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showReadingProgressDialog(Book book) {
    final currentPageController = TextEditingController(text: book.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Reading Progress',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current page: ${book.currentPage}',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentPageController,
              decoration: const InputDecoration(
                labelText: 'New page number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPage = int.tryParse(currentPageController.text);
              if (newPage != null && newPage >= 0 && newPage <= book.totalPages) {
                Navigator.pop(context);
                _updateReadingProgress(book, newPage);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => currentPageController.dispose());
  }

  void _showDailyGoalDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Daily Reading Goal',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _goalController,
          decoration: const InputDecoration(
            labelText: 'Pages per day',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDailyGoal(book);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Book book) {
    String currentReview = book.review ?? '';
    double? currentRating = book.rating;
    final reviewController = TextEditingController(text: currentReview);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Write a Review',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  controller: reviewController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Your review',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  'Rating',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SmoothStarRating(
                  rating: currentRating ?? 0.0,
                  size: 32,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  defaultIconData: Icons.star_border,
                  starCount: 5,
                  allowHalfRating: true,
                  spacing: 2.0,
                  color: Colors.amber,
                  borderColor: Colors.amber,
                  onRatingChanged: (value) {
                    currentRating = value;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (currentRating != null) {
                await _updateReview(book,
                  review: reviewController.text.trim(),
                  rating: currentRating,
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => reviewController.dispose());
  }

  Widget _buildBookHeader(Book book, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'book-cover-${book.id}',
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: book.coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(book.coverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: book.coverUrl == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.book,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.currentPage}/${book.totalPages} pages',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Started ${_formatDate(book.startDate)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (book.finishDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed ${_formatDate(book.finishDate!)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassmorphicContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: book.progressPercentage / 100,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.progressPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${book.pagesRemaining} pages remaining',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingHistory(Book book) {
    if (book.readingHistory.isEmpty) return const SizedBox.shrink();

    final history = book.readingHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last7Days = history.reversed.take(7).toList();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading History',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < last7Days.length) {
                            final date = DateTime.parse(last7Days[index].key);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: last7Days.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: last7Days.length,
              itemBuilder: (context, index) {
                final entry = last7Days[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${_formatDate(DateTime.parse(entry.key))}:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value} pages',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildHighlights(Book book) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Highlights',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _highlightController,
              decoration: InputDecoration(
                hintText: 'Add a highlight...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addHighlight(book),
                ),
              ),
              onSubmitted: (_) => _addHighlight(book),
            ),
            if (book.highlights.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: book.highlights.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            book.highlights[index],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          onPressed: () async {
                            final updatedHighlights = List<String>.from(book.highlights)
                              ..removeAt(index);
                            final updatedBook = book.copyWith(highlights: updatedHighlights);
                            await FirebaseService().updateBook(updatedBook);
                          },
                          tooltip: 'Delete highlight',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildReview(Book book) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Review',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showReviewDialog(book),
                ),
              ],
            ),
            if (book.rating != null) ...[
              const SizedBox(height: 8),
              SmoothStarRating(
                rating: book.rating ?? 0.0,
                size: 24,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
                starCount: 5,
                allowHalfRating: true,
                spacing: 2.0,
                color: Colors.amber,
                borderColor: Colors.amber,
                onRatingChanged: null,
              ),
            ],
            if (book.review != null && book.review!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                book.review!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildActionButtons(Book book, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showReadingProgressDialog(book),
              icon: const Icon(Icons.edit),
              label: const Text('Update Progress'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (book.pdfPath != null)
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _openPdfViewer(book),
                icon: const Icon(Icons.menu_book),
                label: const Text('Read PDF'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openPdfViewer(Book book) {
    if (book.pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF available for this book'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          book: book,
          onPageChanged: (page) {
            _updateReadingProgress(book, page);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Book?>(
      stream: FirebaseService().getBookStream(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final book = snapshot.data!;
        final theme = Theme.of(context);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: book.coverUrl != null
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.colorScheme.primary,
                        ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      book.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: book.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      final updatedBook = book.copyWith(isFavorite: !book.isFavorite);
                      await FirebaseService().updateBook(updatedBook);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookHeader(book, theme),
                    _buildActionButtons(book, theme),
                    const SizedBox(height: 16),
                    _buildReadingHistory(book),
                    const SizedBox(height: 16),
                    _buildHighlights(book),
                    const SizedBox(height: 16),
                    _buildReview(book),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToQuotes() {
    context.go('/books/${widget.bookId}/quotes');
  }
}

class PdfViewerScreen extends StatefulWidget {
  final Book book;
  final Function(int) onPageChanged;

  const PdfViewerScreen({
    super.key,
    required this.book,
    required this.onPageChanged,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  int _currentPage = 0;
  bool _isReading = false;
  DateTime? _readingStartTime;
  Timer? _readingTimer;
  int _readingMinutes = 0;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _currentPage = widget.book.currentPage;
    _startReadingSession();
  }

  @override
  void dispose() {
    _stopReadingSession();
    _pdfViewerController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _startReadingSession() {
    if (!_isReading) {
      setState(() {
        _isReading = true;
        _readingStartTime = DateTime.now();
      });
      _readingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          _readingMinutes++;
        });
        _updateReadingStreak();
      });
    }
  }

  void _stopReadingSession() {
    if (_isReading) {
      _readingTimer?.cancel();
      if (_readingStartTime != null) {
        // final session = ReadingSession(
        //   id: DateTime.now().millisecondsSinceEpoch.toString(),
        //   startTime: _readingStartTime!,
        //   endTime: DateTime.now(),
        //   startPage: widget.book.currentPage,
        //   endPage: _currentPage,
        //   notes: [],
        // );
        final session = ReadingSession(
          id: '1',
          bookId: 'abc',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          startPage: 10,
          endPage: 20,
          pagesRead: 10,
          // mood: 'neutral',
        );

        FirebaseService().addReadingSession(session);
      }
      setState(() {
        _isReading = false;
        _readingStartTime = null;
      });
    }
  }

  void _updateReadingStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    
    final updatedStreak = Map<String, int>.from(widget.book.readingStreak);
    final currentStreak = widget.book.currentStreak;
    
    if (updatedStreak.containsKey(today)) {
      // Already read today, update the streak
      updatedStreak[today] = currentStreak;
    } else if (updatedStreak.containsKey(yesterday)) {
      // Read yesterday, increment streak
      updatedStreak[today] = currentStreak + 1;
    } else {
      // Start new streak
      updatedStreak[today] = 1;
    }

    final updatedBook = widget.book.copyWith(
      readingStreak: updatedStreak,
      lastReadingSession: DateTime.now(),
    );
    await FirebaseService().updateBook(updatedBook);
  }

  void _toggleBookmark() async {
    final updatedBookmarks = List<int>.from(widget.book.bookmarks);
    if (updatedBookmarks.contains(_currentPage)) {
      updatedBookmarks.remove(_currentPage);
    } else {
      updatedBookmarks.add(_currentPage);
      updatedBookmarks.sort();
    }

    final updatedBook = widget.book.copyWith(bookmarks: updatedBookmarks);
    await FirebaseService().updateBook(updatedBook);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedBookmarks.contains(_currentPage)
              ? 'Bookmark added'
              : 'Bookmark removed'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: widget.book.bookmarks.isEmpty
              ? const Center(child: Text('No bookmarks yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.book.bookmarks.length,
                  itemBuilder: (context, index) {
                    final page = widget.book.bookmarks[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text('Page $page'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final updatedBookmarks = List<int>.from(widget.book.bookmarks)
                            ..remove(page);
                          final updatedBook = widget.book.copyWith(
                            bookmarks: updatedBookmarks,
                          );
                          await FirebaseService().updateBook(updatedBook);
                          if (mounted) {
                            Navigator.pop(context);
                            _showBookmarksDialog();
                          }
                        },
                      ),
                      onTap: () {
                        _pdfViewerController.jumpToPage(page);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    _hideControlsTimer?.cancel();
    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _showControls ? AppBar(
        title: Text(widget.book.title),
        actions: [
          IconButton(
            icon: Icon(
              widget.book.bookmarks.contains(_currentPage)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: _showBookmarksDialog,
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              _pdfViewerController.zoomLevel = 1.5;
            },
          ),
        ],
      ) : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            SfPdfViewer.file(
              File(widget.book.pdfPath!),
              controller: _pdfViewerController,
              initialPageNumber: _currentPage,
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
                widget.onPageChanged(_currentPage);
              },
            ),
            if (_showControls) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: colorScheme.surface.withOpacity(0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reading Time: ${_readingMinutes}m',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current Streak: ${widget.book.currentStreak} days',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: colorScheme.surface.withOpacity(0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _pdfViewerController.previousPage();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                      Text(
                        'Page $_currentPage of ${widget.book.totalPages}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _pdfViewerController.nextPage();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 