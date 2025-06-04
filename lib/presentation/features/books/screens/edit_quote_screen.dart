import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:uuid/uuid.dart';

import '../../../../core/di/app_module.dart';
import '../../../../data/models/quote.dart';

class EditQuoteScreen extends ConsumerStatefulWidget {
  final String bookId;
  final Quote? quote;

  const EditQuoteScreen({
    super.key,
    required this.bookId,
    this.quote,
  });

  @override
  ConsumerState<EditQuoteScreen> createState() => _EditQuoteScreenState();
}

class _EditQuoteScreenState extends ConsumerState<EditQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quoteController;
  late final TextEditingController _pageController;
  late final TextEditingController _noteController;
  late final TextEditingController _tagController;
  late List<String> _tags;
  late String _category;
  late double? _rating;
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
  void initState() {
    super.initState();
    _quoteController = TextEditingController(text: widget.quote?.text ?? '');
    _pageController = TextEditingController(
      text: widget.quote?.pageNumber?.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.quote?.note ?? '');
    _tagController = TextEditingController();
    _tags = List.from(widget.quote?.tags ?? []);
    _category = widget.quote?.category ?? 'general';
    _rating = widget.quote?.rating;
  }

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

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quote = widget.quote?.copyWith(
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
      ) ?? Quote(
        id: const Uuid().v4(),
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

      final firebaseService = ref.read(firebaseServiceProvider);
      if (widget.quote == null) {
        await firebaseService.addQuote(quote);
      } else {
        await firebaseService.updateQuote(quote);
      }

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
          widget.quote == null ? 'Add Quote' : 'Edit Quote',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      onPressed: _saveQuote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.quote == null ? 'Add Quote' : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
    );
  }
} 