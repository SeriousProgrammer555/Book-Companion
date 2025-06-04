import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/di/app_module.dart';
import '../../../../data/models/book.dart';
import '../../../widgets/glassmorphic_container.dart';

// Custom color constants to match drawer theme
const Color kPrimaryBlue = Color(0xFF4A90E2);
const Color kDeepPurple = Color(0xFF7E57C2);
const Color kLightBlue = Color(0xFF64B5F6);
const Color kLightPurple = Color(0xFF9575CD);
const Color kDarkBackground = Color(0xFF1A1A2F);
const Color kCardBackground = Color(0xFF2A2A3F);
const Color kWhite = Colors.white;
const Color kWhite70 = Colors.white70;

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _publishedDateController = TextEditingController();
  String _status = 'want_to_read';
  bool _isLoading = false;
  String? _pdfPath;
  String? _pdfFileName;
  int? _pdfPageCount;
  String? _selectedPdfPath;
  String? _selectedCategory;
  String? _selectedLanguage;
  DateTime? _selectedDate;
  String? _error;
  final bool _isFavorite = false;

  final List<String> _categories = [
    'Fiction', 'Non-Fiction', 'Science Fiction', 'Fantasy', 'Mystery',
    'Romance', 'Biography', 'History', 'Science', 'Technology',
    'Philosophy', 'Self-Help', 'Business', 'Education', 'Other'
  ];

  final List<String> _languages = [
    'English', 'Spanish', 'French', 'German', 'Italian',
    'Portuguese', 'Russian', 'Chinese', 'Japanese', 'Arabic', 'Other'
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    _coverUrlController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _publishedDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (kIsWeb) {
          // Web platform: use bytes
          if (file.bytes != null) {
            final bytes = file.bytes!;
            final document = PdfDocument(inputBytes: bytes);
            final pageCount = document.pages.count;

            setState(() {
              _pdfPath = null; // No local file path on web
              _pdfFileName = file.name;
              _pdfPageCount = pageCount;
              _totalPagesController.text = pageCount.toString();
              _selectedPdfPath = 'web_upload://${file.name}'; // Indicate web upload
              _error = null;
            });

            // Extract metadata
            final documentInfo = document.documentInformation;
            if (documentInfo.title.isNotEmpty) _titleController.text = documentInfo.title;
            if (documentInfo.author.isNotEmpty) _authorController.text = documentInfo.author;

            document.dispose();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF uploaded successfully: ${file.name}'), backgroundColor: Colors.green),
              );
            }
          } else {
            // Should not happen with single file pick, but handle defensively
            setState(() => _error = 'Error: Could not get file bytes on web.');
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Error: Could not get file bytes on web.'), backgroundColor: Colors.red),
               );
             }
          }
        } else {
          // Non-web platforms (Android, iOS, Desktop): use file path and save locally
          if (file.path != null) {
            try {
              final appDir = await getApplicationDocumentsDirectory();
              final pdfDir = Directory('${appDir.path}/pdfs');
              if (!await pdfDir.exists()) {
                await pdfDir.create(recursive: true);
              }

              final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
              final filePath = '${pdfDir.path}/$uniqueFileName';
              final sourceFile = File(file.path!);
              final pdfFile = await sourceFile.copy(filePath);

              final document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
              final pageCount = document.pages.count;

              setState(() {
                _pdfPath = filePath;
                _pdfFileName = file.name;
                _pdfPageCount = pageCount;
                _totalPagesController.text = pageCount.toString();
                _selectedPdfPath = filePath;
                _error = null;
              });

              // Extract metadata
              final documentInfo = document.documentInformation;
              if (documentInfo.title.isNotEmpty) _titleController.text = documentInfo.title;
              if (documentInfo.author.isNotEmpty) _authorController.text = documentInfo.author;

              document.dispose();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF uploaded successfully: ${file.name}'), backgroundColor: Colors.green),
                );
              }
            } catch (e) {
              setState(() => _error = 'Error saving PDF locally: $e');
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Error saving PDF locally: $e'), backgroundColor: Colors.red),
                 );
               }
            }
          } else {
             setState(() => _error = 'Error: Could not get file path on non-web.');
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: Could not get file path on non-web.'), backgroundColor: Colors.red),
                );
              }
          }
        }
      }
    } catch (e) {
      setState(() => _error = 'Error uploading PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _publishedDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPdfPath == null) {
      setState(() => _error = 'Please select a PDF file');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final book = Book(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        totalPages: _pdfPageCount ?? 0,
        currentPage: 0,
        coverUrl: _coverUrlController.text.trim().isEmpty ? null : _coverUrlController.text.trim(),
        status: _status,
        isFavorite: _isFavorite,
        pdfPath: _selectedPdfPath,
        startDate: DateTime.now(),
        category: _selectedCategory,
        language: _selectedLanguage,
        description: _descriptionController.text.trim(),
        isbn: _isbnController.text.trim(),
        publisher: _publisherController.text.trim(),
        publishedDate: _selectedDate,
      );

      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.addBook(book);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _error = 'Error adding book: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding book: $e'),
            backgroundColor: Colors.red,
          ),
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
      backgroundColor: kDarkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kDarkBackground,
              Color(0xFF2A1A4A),
              Color(0xFF1A2A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: GlassmorphicContainer(
                      height: 800,
                      blurRadius: 20,
                      borderWidth: 2,
                      borderRadius: 24,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kPrimaryBlue.withOpacity(0.1),
                          kDeepPurple.withOpacity(0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kLightBlue.withOpacity(0.5),
                          kLightPurple.withOpacity(0.1),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 64,
                                color: kLightBlue,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Add New Book',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kWhite,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start your reading journey',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: kWhite70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              if (_error != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red.shade300),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: TextStyle(color: Colors.red.shade300),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        color: Colors.red.shade300,
                                        onPressed: () => setState(() => _error = null),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                              // PDF Upload Section
                              Card(
                                elevation: 0,
                                color: kCardBackground.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: kLightBlue.withOpacity(0.2),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: _pickPDF,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _selectedPdfPath != null ? Icons.picture_as_pdf : Icons.upload_file,
                                          size: 48,
                                          color: kLightBlue,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _pdfFileName ?? 'Select PDF File',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: kWhite,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (_pdfPageCount != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '$_pdfPageCount pages',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: kWhite70,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 50.ms),

                              const SizedBox(height: 24),

                              // Book Details Section with updated styling
                              _buildTextField(
                                controller: _titleController,
                                label: 'Title',
                                icon: Icons.title,
                                required: true,
                              ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 100.ms),
                              
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: _authorController,
                                label: 'Author',
                                icon: Icons.person,
                                required: true,
                              ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 150.ms),
                              
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                icon: Icons.description,
                                maxLines: 3,
                              ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 200.ms),

                              const SizedBox(height: 24),

                              FilledButton(
                                onPressed: _isLoading ? null : _addBook,
                                style: FilledButton.styleFrom(
                                  backgroundColor: kLightBlue,
                                  foregroundColor: kWhite,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: kWhite)
                                    : const Text(
                                        'Add Book',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 300.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: kWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kWhite70),
        prefixIcon: Icon(icon, color: kLightBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: kLightBlue.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: kLightBlue,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: kCardBackground.withOpacity(0.3),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Please enter ${label.toLowerCase()}' : null
          : null,
    );
  }

  Widget _buildStatusSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'want_to_read',
              icon: Icon(Icons.bookmark_border),
              label: Text('Want to Read'),
            ),
            ButtonSegment(
              value: 'reading',
              icon: Icon(Icons.menu_book),
              label: Text('Reading'),
            ),
            ButtonSegment(
              value: 'completed',
              icon: Icon(Icons.check_circle_outline),
              label: Text('Completed'),
            ),
          ],
          selected: {_status},
          onSelectionChanged: (Set<String> selection) {
            setState(() => _status = selection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            selectedBackgroundColor: colorScheme.primary,
            selectedForegroundColor: colorScheme.onPrimary,
            foregroundColor: colorScheme.onSurfaceVariant,
            textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
} 