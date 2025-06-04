import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/di/app_module.dart' as firebase;
import '../../../../data/models/book.dart';
import '../../../../data/services/storage/firebase_service.dart' as firebase hide firebaseServiceProvider;
import '../../../widgets/book/book_list_item.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glassmorphic_container.dart';

enum ViewMode { grid, list }

enum SortOption { title, author, dateAdded, progress }

enum BookStatus { reading, completed, wantToRead }

// Provider for explore screen state
final exploreScreenProvider = StateNotifierProvider<ExploreScreenNotifier, ExploreScreenState>((ref) {
  final firebaseService = ref.watch(firebase.firebaseServiceProvider);
  return ExploreScreenNotifier(firebaseService);
});

class ExploreScreenState {
  final String searchQuery;
  final BookStatus? selectedStatus;
  final SortOption sortBy;
  final ViewMode viewMode;
  final bool isLoading;
  final String? error;
  final List<Book> books;
  final List<Book> filteredBooks;
  final bool showStatistics;
  final bool showReadingGoals;

  const ExploreScreenState({
    this.searchQuery = '',
    this.selectedStatus,
    this.sortBy = SortOption.dateAdded,
    this.viewMode = ViewMode.grid,
    this.isLoading = true,
    this.error,
    this.books = const [],
    this.filteredBooks = const [],
    this.showStatistics = false,
    this.showReadingGoals = false,
  });

  ExploreScreenState copyWith({
    String? searchQuery,
    BookStatus? selectedStatus,
    SortOption? sortBy,
    ViewMode? viewMode,
    bool? isLoading,
    String? error,
    List<Book>? books,
    List<Book>? filteredBooks,
    bool? showStatistics,
    bool? showReadingGoals,
  }) {
    return ExploreScreenState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      sortBy: sortBy ?? this.sortBy,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      books: books ?? this.books,
      filteredBooks: filteredBooks ?? this.filteredBooks,
      showStatistics: showStatistics ?? this.showStatistics,
      showReadingGoals: showReadingGoals ?? this.showReadingGoals,
    );
  }
}

class ExploreScreenNotifier extends StateNotifier<ExploreScreenState> {
  final firebase.FirebaseService _firebaseService;
  Timer? _debounceTimer;

  ExploreScreenNotifier(this._firebaseService) : super(const ExploreScreenState()) {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final books = await _firebaseService.getAllBooks();

      // Sort books by date added by default
      books.sort((a, b) => b.startDate.compareTo(a.startDate));

      if (books.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          books: [],
          filteredBooks: [],
          error: null, // Changed to null to show empty state widget instead
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          books: books,
          filteredBooks: books,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading books: $e',
      );
    }
  }

  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        state = state.copyWith(
          searchQuery: '',
          filteredBooks: state.books,
        );
        return;
      }

      final filtered = state.books.where((book) {
        final titleMatch = book.title.toLowerCase().contains(query.toLowerCase());
        final authorMatch = book.author.toLowerCase().contains(query.toLowerCase());
        return titleMatch || authorMatch;
      }).toList();

      state = state.copyWith(
        searchQuery: query,
        filteredBooks: filtered,
      );
    });
  }

  void updateSortOption(SortOption option) {
    List<Book> sorted = List.from(state.filteredBooks);
    switch (option) {
      case SortOption.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.author:
        sorted.sort((a, b) => a.author.compareTo(b.author));
        break;
      case SortOption.dateAdded:
        sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
      case SortOption.progress:
        sorted.sort((a, b) {
          final aProgress = a.currentPage / (a.totalPages > 0 ? a.totalPages : 1);
          final bProgress = b.currentPage / (b.totalPages > 0 ? b.totalPages : 1);
          return bProgress.compareTo(aProgress);
        });
        break;
    }

    state = state.copyWith(
      sortBy: option,
      filteredBooks: sorted,
    );
  }

  void updateViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void filterByStatus(BookStatus? status) {
    if (status == null) {
      state = state.copyWith(
        selectedStatus: null,
        filteredBooks: state.books,
      );
      return;
    }

    final filtered = state.books.where((book) => book.status == status.name).toList();
    state = state.copyWith(
      selectedStatus: status,
      filteredBooks: filtered,
    );
  }

  Future<void> toggleFavorite(Book book) async {
    try {
      final updatedBook = book.copyWith(isFavorite: !book.isFavorite);
      await _firebaseService.updateBook(updatedBook);

      // Update the book in the local state instead of reloading all books
      final updatedBooks = state.books.map((b) => b.id == book.id ? updatedBook : b).toList();
      final updatedFilteredBooks = state.filteredBooks.map((b) => b.id == book.id ? updatedBook : b).toList();

      state = state.copyWith(
        books: updatedBooks,
        filteredBooks: updatedFilteredBooks,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update favorite status: ${e.toString()}',
      );
    }
  }

  void toggleStatistics() {
    state = state.copyWith(showStatistics: !state.showStatistics);
  }

  void toggleReadingGoals() {
    state = state.copyWith(showReadingGoals: !state.showReadingGoals);
  }

  Map<String, dynamic> getReadingStatistics() {
    final books = state.books;
    final totalBooks = books.length;
    final completedBooks = books.where((b) => b.status == 'completed').length;
    final readingBooks = books.where((b) => b.status == 'reading').length;
    final wantToReadBooks = books.where((b) => b.status == 'want_to_read').length;

    final totalPages = books.fold<int>(0, (sum, book) => sum + book.totalPages);
    final pagesRead = books.fold<int>(0, (sum, book) => sum + book.currentPage);
    final readingTime = books.fold<int>(0, (sum, book) => sum + book.totalReadingTimeMinutes);

    return {
      'totalBooks': totalBooks,
      'completedBooks': completedBooks,
      'readingBooks': readingBooks,
      'wantToReadBooks': wantToReadBooks,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
      'readingTime': readingTime,
    };
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  Widget _buildStatisticsSection(Map<String, dynamic> stats) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassmorphicContainer(
      height: 200,
      borderRadius: 16,
      borderWidth: 1,
      blurRadius: 10,
      linearGradient: LinearGradient(
        colors: [
          colorScheme.primary.withOpacity(0.1),
          colorScheme.primary.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref.read(exploreScreenProvider.notifier).toggleStatistics(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard('Total Books', stats['totalBooks'].toString(), Icons.book),
                  _buildStatCard('Completed', stats['completedBooks'].toString(), Icons.check_circle),
                  _buildStatCard('Reading', stats['readingBooks'].toString(), Icons.auto_stories),
                  _buildStatCard('Want to Read', stats['wantToReadBooks'].toString(), Icons.bookmark),
                  _buildStatCard('Total Pages', stats['totalPages'].toString(), Icons.pages),
                  _buildStatCard('Pages Read', stats['pagesRead'].toString(), Icons.menu_book),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.0, color: colorScheme.primary),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreScreenProvider);
    final notifier = ref.read(exploreScreenProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: notifier.updateSortOption,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.dateAdded,
                child: Text('Date Added'),
              ),
              const PopupMenuItem(
                value: SortOption.title,
                child: Text('Title'),
              ),
              const PopupMenuItem(
                value: SortOption.author,
                child: Text('Author'),
              ),
              const PopupMenuItem(
                value: SortOption.progress,
                child: Text('Reading Progress'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(state.viewMode == ViewMode.grid ? Icons.list : Icons.grid_view),
            onPressed: () => notifier.updateViewMode(
              state.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: notifier.toggleStatistics,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: notifier.updateSearchQuery,
            ),
          ),
          if (state.showStatistics)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatisticsSection(notifier.getReadingStatistics()),
            ),
          Expanded(
            child: state.filteredBooks.isEmpty
                ? EmptyState(
              title: state.searchQuery.isEmpty ? 'No Books Yet' : 'No Results Found',
              message: state.searchQuery.isEmpty
                  ? 'Start by adding some books to your collection'
                  : 'Try adjusting your search terms',
              icon: Icons.book,
            )
                : state.viewMode == ViewMode.grid
                ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.filteredBooks.length,
              itemBuilder: (context, index) {
                final book = state.filteredBooks[index];
                return BookListItem(
                  book: book,
                  onTap: () => context.push('/books/${book.id}'),
                  onFavoriteToggle: () => notifier.toggleFavorite(book),
                );
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredBooks.length,
              itemBuilder: (context, index) {
                final book = state.filteredBooks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BookListItem(
                    book: book,
                    onTap: () => context.push('/books/${book.id}'),
                    onFavoriteToggle: () => notifier.toggleFavorite(book),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}