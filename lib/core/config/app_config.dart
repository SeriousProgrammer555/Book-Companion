
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig());

class AppConfig {
  static const String appName = 'Book Companion';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Track your reading journey';

  // API Keys and Endpoints
  static const String googleBooksApiKey = 'YOUR_API_KEY';
  static const String googleBooksApiEndpoint = 'https://www.googleapis.com/books/v1';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String firstRunKey = 'first_run';
  static const String userIdKey = 'user_id';
  static const String authTokenKey = 'auth_token';

  // Feature Flags
  static const bool enableCloudSync = true;
  static const bool enableNotifications = true;
  static const bool enablePdfSupport = true;

  // Cache Settings
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxCachedBooks = 100;
  static const int maxCachedQuotes = 500;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Reading Goals
  static const int defaultDailyGoal = 30; // pages
  static const int defaultWeeklyGoal = 210; // pages
  static const int defaultMonthlyGoal = 900; // pages

  // Logger
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.debug : Level.info,
  );

  // Shared Preferences
  static late SharedPreferences prefs;

  static Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();

    // Set a default auth token if none exists
    if (prefs.getString(authTokenKey) == null) {
      await prefs.setString(authTokenKey, 'default_auth_token');
      await prefs.setString(userIdKey, 'default_user_id');
    }

    logger.i('AppConfig initialized');
  }

  // Theme Mode
  static bool get isDarkMode => prefs.getBool(themeKey) ?? true;
  static Future<void> setDarkMode(bool value) async {
    await prefs.setBool(themeKey, value);
  }

  // First Run
  static bool get isFirstRun => prefs.getBool(firstRunKey) ?? true;
  static Future<void> setFirstRunComplete() async {
    await prefs.setBool(firstRunKey, false);
  }

  // User ID
  static String? get userId => prefs.getString(userIdKey);
  static Future<void> setUserId(String id) async {
    await prefs.setString(userIdKey, id);
  }

  // Auth Token
  static String? get authToken => prefs.getString(authTokenKey);
  static Future<void> setAuthToken(String token) async {
    await prefs.setString(authTokenKey, token);
  }
  static Future<void> clearAuthToken() async {
    await prefs.remove(authTokenKey);
  }
}





