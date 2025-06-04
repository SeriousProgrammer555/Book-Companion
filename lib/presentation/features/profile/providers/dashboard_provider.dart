import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import '../../../../data/models/activity.dart';
import '../../../../data/models/book.dart';
import '../../../../data/services/storage/firebase_service.dart';

// Cache duration
const _cacheDuration = Duration(minutes: 5);

// State class to hold dashboard data
class DashboardState {
  final List<Book> allBooks;
  final List<Book> readingBooks;
  final List<Book> completedBooks;
  final List<Book> wantToReadBooks;
  final List<Book> currentlyReadingBooks;
  final String selectedTimeRange;
  final bool isLoading;
  final String? error;
  final int currentStreak;
  final int dailyGoal;
  final int dailyProgress;
  final DateTime lastReadingDate;
  final List<Book> recommendedBooks;
  final List<ReadingSession> recentSessions;
  final List<DateTime> readingDays;
  final List<int> readingTimes;
  final double dailyAverage;
  final int totalReadingTime;
  final String bestDay;
  final List<Activity> recentActivities;
  final DateTime? lastUpdated;

  DashboardState({
    required this.allBooks,
    required this.readingBooks,
    this.completedBooks = const [],
    this.wantToReadBooks = const [],
    this.currentlyReadingBooks = const [],
    this.selectedTimeRange = 'This Month',
    this.isLoading = false,
    this.error,
    this.currentStreak = 0,
    this.dailyGoal = 30,
    this.dailyProgress = 0,
    DateTime? lastReadingDate,
    this.recommendedBooks = const [],
    this.recentSessions = const [],
    this.readingDays = const [],
    this.readingTimes = const [],
    this.dailyAverage = 0.0,
    this.totalReadingTime = 0,
    this.bestDay = '',
    this.recentActivities = const [],
    this.lastUpdated,
  }) : lastReadingDate = lastReadingDate ?? DateTime.now();

  DashboardState copyWith({
    List<Book>? allBooks,
    List<Book>? readingBooks,
    List<Book>? completedBooks,
    List<Book>? wantToReadBooks,
    List<Book>? currentlyReadingBooks,
    String? selectedTimeRange,
    bool? isLoading,
    String? error,
    int? currentStreak,
    int? dailyGoal,
    int? dailyProgress,
    DateTime? lastReadingDate,
    List<Book>? recommendedBooks,
    List<ReadingSession>? recentSessions,
    List<DateTime>? readingDays,
    List<int>? readingTimes,
    double? dailyAverage,
    int? totalReadingTime,
    String? bestDay,
    List<Activity>? recentActivities,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      allBooks: allBooks ?? this.allBooks,
      readingBooks: readingBooks ?? this.readingBooks,
      completedBooks: completedBooks ?? this.completedBooks,
      wantToReadBooks: wantToReadBooks ?? this.wantToReadBooks,
      currentlyReadingBooks: currentlyReadingBooks ?? this.currentlyReadingBooks,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentStreak: currentStreak ?? this.currentStreak,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      recommendedBooks: recommendedBooks ?? this.recommendedBooks,
      recentSessions: recentSessions ?? this.recentSessions,
      readingDays: readingDays ?? this.readingDays,
      readingTimes: readingTimes ?? this.readingTimes,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      bestDay: bestDay ?? this.bestDay,
      recentActivities: recentActivities ?? this.recentActivities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isCacheValid {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated!) < _cacheDuration;
  }
}

// Notifier class to manage dashboard state
class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref ref;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _booksSubscription;
  StreamSubscription? _sessionsSubscription;
  StreamSubscription? _activitiesSubscription;
  Timer? _refreshTimer;

  DashboardNotifier(this.ref) : super(DashboardState(
    allBooks: [],
    readingBooks: [],
    completedBooks: [],
    wantToReadBooks: [],
    currentlyReadingBooks: [],
  )) {
    _initializeData();
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(_cacheDuration, (_) => _loadDashboardData());
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    _sessionsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeData() {
    if (state.isCacheValid) return;
    _loadDashboardData();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Listen to books
    _booksSubscription?.cancel();
    _booksSubscription = _database
        .ref()
        .child('books')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .listen((event) {
      if (!state.isLoading && event.snapshot.exists) {
        _processBooksUpdate(event.snapshot);
      }
    });

    // Listen to reading sessions
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _database
        .ref()
        .child('reading_sessions')
        .orderByChild('userId')
        .equalTo(userId)
        .limitToLast(10)
        .onValue
        .listen((event) {
      if (!state.isLoading && event.snapshot.exists) {
        _processSessionsUpdate(event.snapshot);
      }
    });

    // Listen to activities
    _activitiesSubscription?.cancel();
    _activitiesSubscription = _database
        .ref()
        .child('activities')
        .orderByChild('userId')
        .equalTo(userId)
        .limitToLast(10)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final activities = data.entries.map((entry) {
          final activityData = Map<String, dynamic>.from(entry.value as Map);
          activityData['id'] = entry.key;
          return Activity.fromJson(activityData);
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(recentActivities: activities, lastUpdated: DateTime.now());
      }
    });
  }

  void _processBooksUpdate(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    final books = data.entries.map((entry) {
      final bookData = Map<String, dynamic>.from(entry.value as Map);
      bookData['id'] = entry.key;
      return Book.fromJson(bookData);
    }).toList();

    final readingBooks = books.where((b) => b.status == 'reading').toList();
    final completedBooks = books.where((b) => b.status == 'completed').toList();
    final wantToReadBooks = books.where((b) => b.status == 'want_to_read').toList();

    state = state.copyWith(
      allBooks: books,
      readingBooks: readingBooks,
      completedBooks: completedBooks,
      wantToReadBooks: wantToReadBooks,
      lastUpdated: DateTime.now(),
    );

    _updateReadingStats();
  }

  void _processSessionsUpdate(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    final sessions = data.entries.map((entry) {
      final sessionData = Map<String, dynamic>.from(entry.value as Map);
      sessionData['id'] = entry.key;
      return ReadingSession.fromJson(sessionData);
    }).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    state = state.copyWith(
      recentSessions: sessions,
      lastUpdated: DateTime.now(),
    );

    _updateReadingStats();
  }

  Future<void> _loadDashboardData() async {
    if (state.isLoading) return;
    if (state.isCacheValid) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get books
      final booksSnapshot = await _database
          .ref()
          .child('books')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      // Get reading sessions
      final sessionsSnapshot = await _database
          .ref()
          .child('reading_sessions')
          .orderByChild('userId')
          .equalTo(userId)
          .limitToLast(10)
          .get();

      // Get user preferences
      final userPrefsSnapshot = await _database
          .ref()
          .child('users')
          .child(userId)
          .child('preferences')
          .child('reading_goals')
          .get();

      // Get activities
      final activitiesSnapshot = await _database
          .ref()
          .child('activities')
          .orderByChild('userId')
          .equalTo(userId)
          .limitToLast(10)
          .get();

      // Process books
      List<Book> books = [];
      if (booksSnapshot.exists) {
        final data = booksSnapshot.value as Map<dynamic, dynamic>;
        books = data.entries.map((entry) {
          final bookData = Map<String, dynamic>.from(entry.value as Map);
          bookData['id'] = entry.key;
          return Book.fromJson(bookData);
        }).toList();
      }

      // Process sessions
      List<ReadingSession> sessions = [];
      if (sessionsSnapshot.exists) {
        final data = sessionsSnapshot.value as Map<dynamic, dynamic>;
        sessions = data.entries.map((entry) {
          final sessionData = Map<String, dynamic>.from(entry.value as Map);
          sessionData['id'] = entry.key;
          return ReadingSession.fromJson(sessionData);
        }).toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));
      }

      // Process user preferences
      final userPrefs = userPrefsSnapshot.value as Map<dynamic, dynamic>?;
      final dailyGoal = userPrefs?['dailyGoal'] ?? 30;

      // Process activities
      List<Activity> activities = [];
      if (activitiesSnapshot.exists) {
        final data = activitiesSnapshot.value as Map<dynamic, dynamic>;
        activities = data.entries.map((entry) {
          final activityData = Map<String, dynamic>.from(entry.value as Map);
          activityData['id'] = entry.key;
          return Activity.fromJson(activityData);
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      // Update state with all data
      state = state.copyWith(
        isLoading: false,
        allBooks: books,
        readingBooks: books.where((b) => b.status == 'reading').toList(),
        completedBooks: books.where((b) => b.status == 'completed').toList(),
        wantToReadBooks: books.where((b) => b.status == 'want_to_read').toList(),
        recentSessions: sessions,
        dailyGoal: dailyGoal,
        recentActivities: activities,
        lastUpdated: DateTime.now(),
      );

      _updateReadingStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _updateReadingStats() {
    final sessions = state.recentSessions;
    if (sessions.isEmpty) return;

    // Calculate reading streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var currentStreak = 0;
    var lastReadingDay = today;

    for (final session in sessions) {
      final sessionDay = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDay == lastReadingDay) continue;
      if (sessionDay.difference(lastReadingDay).inDays > 1) break;

      currentStreak++;
      lastReadingDay = sessionDay;
    }

    // Calculate daily average and total time
    final totalTime = sessions.fold<int>(
      0,
      (sum, session) => sum + session.endTime.difference(session.startTime).inMinutes,
    );

    final dailyAverage = sessions.isEmpty
        ? 0.0
        : totalTime / sessions.length;

    // Find best reading day
    final dayStats = <String, int>{};
    for (final session in sessions) {
      final day = session.startTime.weekday;
      final dayName = _getDayName(day);
      dayStats[dayName] = (dayStats[dayName] ?? 0) + 
          session.endTime.difference(session.startTime).inMinutes;
    }

    final bestDay = dayStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Update state with calculated stats
    state = state.copyWith(
      currentStreak: currentStreak,
      dailyAverage: dailyAverage,
      totalReadingTime: totalTime,
      bestDay: bestDay,
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(lastUpdated: null);
    await _loadDashboardData();
  }

  void updateTimeRange(String timeRange) {
    state = state.copyWith(selectedTimeRange: timeRange);
  }

  Future<void> updateDailyGoal(int minutes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database
          .ref()
          .child('users')
          .child(userId)
          .child('preferences')
          .child('reading_goals')
          .update({'dailyGoal': minutes});

      state = state.copyWith(dailyGoal: minutes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateReadingProgress(int minutes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');


      final session = ReadingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: state.readingBooks.first.id,
        startTime: DateTime.now().subtract(Duration(minutes: minutes)),
        endTime: DateTime.now(),
        startPage: 0, // replace with actual start page if available
        endPage: 0,   // replace with actual end page if available
        pagesRead: 0,
        // mood: 'neutral',
      );



      await _database
          .ref()
          .child('reading_sessions')
          .child(session.id)
          .set(session.toJson());

      state = state.copyWith(
        dailyProgress: minutes,
        lastReadingDate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});

final dashboardFutureProvider = FutureProvider<List<Book>>((ref) async {
  final firebaseService = FirebaseService();
  final books = await firebaseService.getAllBooks();
  return books.map((book) => Book.fromJson(book.toJson())).toList();
}); 