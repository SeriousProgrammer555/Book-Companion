import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/book.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../providers/dashboard_provider.dart';

class ReadingProgressSection extends ConsumerStatefulWidget {
  const ReadingProgressSection({super.key});

  @override
  ConsumerState<ReadingProgressSection> createState() => _ReadingProgressSectionState();
}

class _ReadingProgressSectionState extends ConsumerState<ReadingProgressSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Reading Progress',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStreakCard(context, colorScheme, textTheme, state),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDailyGoalCard(context, colorScheme, textTheme, state),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        if (state.readingBooks.isEmpty)
          GlassmorphicContainer(
            height: 200,
            width: double.infinity,
            borderRadius: 16,
            blurRadius: 10,
            borderWidth: 2,
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books in progress',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start reading a book to track your progress',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          GlassmorphicContainer(
            height: 280,
            width: double.infinity,
            borderRadius: 16,
            blurRadius: 10,
            borderWidth: 2,
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
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Currently Reading',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: state.readingBooks.length,
                    itemBuilder: (context, index) {
                      final book = state.readingBooks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 300,
                          child: _buildBookCard(book),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, DashboardState state) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reading Streak',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${state.currentStreak} days',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.currentStreak > 0
                  ? 'Keep up the good work!'
                  : 'Start your reading journey today!',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, DashboardState state) {
    final progress = state.dailyProgress / state.dailyGoal;
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: colorScheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Daily Goal',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    _showDailyGoalDialog(context, state);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${state.dailyProgress}/${state.dailyGoal} min',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, DashboardState state) {
    final controller = TextEditingController(text: state.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Reading Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes per day',
            hintText: 'Enter your daily reading goal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                ref.read(dashboardProvider.notifier).updateDailyGoal(value);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number greater than 0'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            book.coverUrl ?? '',
            width: 40,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 60,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.book,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        title: Text(book.title),
        subtitle: Text(book.author),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/book-detail',
              arguments: book.id,
            );
          },
        ),
      ),
    );
  }
}

class OverallReadingProgress extends ConsumerWidget {
  const OverallReadingProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalBooks = state.allBooks.length;
    final completedBooks = state.completedBooks.length;
    final readingBooks = state.readingBooks.length;
    final wantToReadBooks = state.wantToReadBooks.length;

    return GlassmorphicContainer(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  context,
                  'Completed',
                  completedBooks,
                  totalBooks,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  context,
                  'Reading',
                  readingBooks,
                  totalBooks,
                  colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  context,
                  'Want to Read',
                  wantToReadBooks,
                  totalBooks,
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
} 