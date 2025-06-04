import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../data/models/quote.dart';
import '../../../../data/services/storage/firebase_service.dart';


class AddQuoteScreen extends StatefulWidget {
  final String bookId;

  const AddQuoteScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _pageController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String _category = 'general';
  double? _rating;
  bool _isLoading = false;

  final List<String> _categories = [
    'general',
    'inspiration',
    'wisdom',
    'humor',
    'philosophy',
    'science',
    'fiction',
  ];

  @override
  void dispose() {
    _quoteController.dispose();
    _pageController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _addQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quote = Quote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: widget.bookId,
        text: _quoteController.text.trim(),
        pageNumber: _pageController.text.isNotEmpty
            ? int.parse(_pageController.text)
            : null,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        tags: _tags,
        category: _category,
        rating: _rating,
      );

      await FirebaseService().addQuote(quote);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Quote',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quote',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quoteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter your favorite quote...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the quote';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pageController,
                        decoration: const InputDecoration(
                          labelText: 'Page Number (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bookmark),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid page number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rating',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < (_rating ?? 0) ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = _rating == index + 1 ? null : index + 1.0;
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.tag),
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addTag,
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeTag(tag),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add your thoughts about this quote...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _addQuote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Quote'),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
} 