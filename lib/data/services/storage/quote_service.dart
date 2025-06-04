import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/quote.dart';
import 'firebase_service.dart';

class QuoteService {
  final FirebaseService _storageService;

  QuoteService(this._storageService);

  Future<String> exportQuotes(String bookId) async {
    final quotes = await _storageService.getQuotesForBook(bookId);
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'quotes': quotes.map((q) => q.toJson()).toList(),
    };

    final jsonString = jsonEncode(exportData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/quotes_export_$bookId.json');
    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<List<Quote>> importQuotes(String filePath, String bookId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Export file not found');
      }

      final jsonString = await file.readAsString();
      final exportData = jsonDecode(jsonString) as Map<String, dynamic>;

      if (exportData['version'] != '1.0') {
        throw Exception('Unsupported export version');
      }

      final quotesJson = exportData['quotes'] as List<dynamic>;
      final quotes = quotesJson.map((json) {
        final quoteData = Map<String, dynamic>.from(json as Map);
        quoteData['bookId'] = bookId; // Override bookId with current book
        return Quote.fromJson(quoteData);
      }).toList();

      // Save imported quotes
      for (final quote in quotes) {
        await _storageService.addQuote(quote);
      }

      return quotes;
    } catch (e) {
      throw Exception('Error importing quotes: $e');
    }
  }

  Future<Map<String, dynamic>> getQuoteStats(String bookId) async {
    final quotes = await _storageService.getQuotesForBook(bookId);
    final totalQuotes = quotes.length;
    final favoriteQuotes = quotes.where((q) => q.isFavorite).length;
    
    final categories = <String, int>{};
    final tags = <String, int>{};
    var totalRating = 0.0;
    var ratedQuotes = 0;

    for (final quote in quotes) {
      // Count categories
      categories[quote.category] = (categories[quote.category] ?? 0) + 1;
      
      // Count tags
      for (final tag in quote.tags) {
        tags[tag] = (tags[tag] ?? 0) + 1;
      }
      
      // Calculate average rating
      if (quote.rating != null) {
        totalRating += quote.rating!;
        ratedQuotes++;
      }
    }

    // Sort tags and categories by count
    final sortedTags = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalQuotes': totalQuotes,
      'favoriteQuotes': favoriteQuotes,
      'categories': categories,
      'tags': tags,
      'averageRating': ratedQuotes > 0 ? totalRating / ratedQuotes : 0.0,
      'topTags': sortedTags.take(5).map((e) => {'tag': e.key, 'count': e.value}).toList(),
      'topCategories': sortedCategories.take(3).map((e) => {'category': e.key, 'count': e.value}).toList(),
    };
  }
} 