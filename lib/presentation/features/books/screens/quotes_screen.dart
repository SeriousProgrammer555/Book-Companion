import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/di/app_module.dart';
import '../../../../data/models/quote.dart';
import '../../../../data/services/storage/quote_service.dart';
import '../../../widgets/empty_state.dart';
import 'edit_quote_screen.dart';

final quotesProvider = FutureProvider.family<List<Quote>, String>((ref, bookId) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getQuotesForBook(bookId);
});

final quoteStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, bookId) async {
  final quoteService = QuoteService(ref.watch(firebaseServiceProvider));
  return quoteService.getQuoteStats(bookId);
});

class QuotesScreen extends ConsumerStatefulWidget {
  final String bookId;

  const QuotesScreen({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _sortBy = 'date';
  bool _showFavoritesOnly = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = [
    'all',
    'inspiration',
    'notes',
    'highlights',
    'fiction',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Quote> _filterAndSortQuotes(List<Quote> quotes) {
    try {
      var filtered = quotes.where((quote) {
        final searchText = _searchQuery.toLowerCase();
        final quoteText = quote.text.toLowerCase();
        final noteText = quote.note?.toLowerCase() ?? '';
        final tagMatches = quote.tags.any((tag) => tag.toLowerCase().contains(searchText));
        final matchesSearch = quoteText.contains(searchText) || noteText.contains(searchText) || tagMatches;
        final matchesCategory = _selectedCategory == 'all' || (quote.category.toLowerCase() == _selectedCategory.toLowerCase());
        final matchesFavorite = !_showFavoritesOnly || quote.isFavorite;
        return matchesSearch && matchesCategory && matchesFavorite;
      }).toList();
      switch (_sortBy) {
        case 'date':
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'rating':
          filtered.sort((a, b) {
            final ratingA = a.rating ?? 0.0;
            final ratingB = b.rating ?? 0.0;
            return ratingB.compareTo(ratingA);
          });
          break;
        case 'page':
          filtered.sort((a, b) {
            final pageA = a.pageNumber ?? 0;
            final pageB = b.pageNumber ?? 0;
            return pageA.compareTo(pageB);
          });
          break;
      }
      return filtered;
    } catch (e) {
      debugPrint('Error filtering quotes: $e');
      return quotes;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Quotes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                  Navigator.pop(context);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Date Added')),
                DropdownMenuItem(value: 'rating', child: Text('Rating')),
                DropdownMenuItem(value: 'page', child: Text('Page Number')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortBy = value);
                  Navigator.pop(context);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Sort By',
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final quotesAsync = ref.watch(quotesProvider(widget.bookId));
    final statsAsync = ref.watch(quoteStatsProvider(widget.bookId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final quoteService = QuoteService(ref.read(firebaseServiceProvider));
              switch (value) {
                case 'export':
                  final exportPath = await quoteService.exportQuotes(widget.bookId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Quotes exported to: $exportPath')),
                    );
                  }
                  break;
                case 'import':
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );
                  if (result != null) {
                    try {
                      await quoteService.importQuotes(result.files.single.path!, widget.bookId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quotes imported successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error importing quotes: $e')),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Quotes'),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Import Quotes'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search quotes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quote Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.format_quote,
                        label: 'Total',
                        value: stats['totalQuotes'].toString(),
                      ),
                      _StatItem(
                        icon: Icons.favorite,
                        label: 'Favorites',
                        value: stats['favoriteQuotes'].toString(),
                      ),
                      _StatItem(
                        icon: Icons.star,
                        label: 'Avg Rating',
                        value: stats['averageRating'].toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: quotesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (quotes) {
                final filteredQuotes = _filterAndSortQuotes(quotes);
                if (filteredQuotes.isEmpty) {
                  return EmptyState(
                    title: 'No Quotes Found',
                    message: _searchQuery.isNotEmpty 
                        ? 'No quotes match your search.'
                        : 'No quotes have been added for this book yet.',
                    icon: Icons.format_quote,
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = filteredQuotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditQuoteScreen(
                                bookId: widget.bookId,
                                quote: quote,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      quote.text,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      quote.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: quote.isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () async {
                                      final firebaseService = ref.read(firebaseServiceProvider);
                                      await firebaseService.updateQuote(
                                        quote.copyWith(isFavorite: !quote.isFavorite),
                                      );
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              if (quote.note != null && quote.note!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  quote.note!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (quote.pageNumber != null)
                                    Chip(
                                      label: Text('Page ${quote.pageNumber}'),
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    ),
                                  if (quote.rating != null)
                                    Chip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, size: 16),
                                          const SizedBox(width: 4),
                                          Text(quote.rating!.toStringAsFixed(1)),
                                        ],
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    ),
                                  Chip(
                                    label: Text(quote.category),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                  ...quote.tags.map((tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditQuoteScreen(
                bookId: widget.bookId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
} 