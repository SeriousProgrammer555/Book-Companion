import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/routes.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isScrolled
            ? colorScheme.primary.withOpacity(0.95)
            : Colors.transparent,
        title: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'My Reading Journey',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: _isScrolled ? colorScheme.onPrimary : Colors.white),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: _isScrolled ? colorScheme.onPrimary : Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.background,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced Header
              SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  child: Stack(
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
                        right: 10 + (index * 30),
                        bottom: 10,
                        child: Icon(
                          Icons.auto_stories,
                          color: Colors.white.withOpacity(0.2),
                          size: 24,
                        ),
                      )),
                      // Main content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            'Track your reading journey',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2, end: 0, delay: 100.ms),
                          const SizedBox(height: 24),
                          _buildReadingStatsHeader(context, state),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Reading Streak Calendar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildReadingStreakCalendar(context)
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingStatsHeader(BuildContext context, dynamic state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '${state.currentStreak}',
            'Day Streak',
            Icons.local_fire_department,
            Colors.orange,
          ),
          _buildStatItem(
            context,
            '${state.completedBooks.length}',
            'Books Read',
            Icons.menu_book,
            Colors.blue,
          ),
          _buildStatItem(
            context,
            '${state.dailyProgress}',
            'Min Today',
            Icons.timer,
            Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 200.ms);
  }

  Widget _buildStatItem(
      BuildContext context,
      String value,
      String label,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingStreakCalendar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(dashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reading Streak',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${state.currentStreak} days',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GlassmorphicContainer(
          height: 500,
          borderRadius: 24,
          borderWidth: 2,
          blurRadius: 16,
          linearGradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.2),
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
          child: TableCalendar(
            firstDay: DateTime.utc(DateTime.now().year, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: textTheme.titleMedium!,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (state.readingDays.contains(date)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              // Could show details about the day reading activity or jump to logs
            },
            selectedDayPredicate: (day) => false,
          ),
        ),
      ],
    );
  }
}
