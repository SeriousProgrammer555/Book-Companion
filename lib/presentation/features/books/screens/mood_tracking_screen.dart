import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../data/models/mood_log.dart';
import '../../../../data/services/storage/firebase_service.dart';

class MoodTrackingScreen extends StatefulWidget {
  final String bookId;

  const MoodTrackingScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final _firebaseService = FirebaseService();
  String? _selectedMood;
  final String _note = '';
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
      ),
      body: FutureBuilder<List<MoodLog>>(
        future: _firebaseService.getMoodLogs(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final moodLogs = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodInput(),
                const SizedBox(height: 24),
                _buildMoodHistory(moodLogs),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling about this book?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMoodButton('😊', 'Happy'),
                _buildMoodButton('😐', 'Neutral'),
                _buildMoodButton('😢', 'Sad'),
                _buildMoodButton('😡', 'Angry'),
                _buildMoodButton('😴', 'Bored'),
                _buildMoodButton('🤔', 'Thoughtful'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(),
              ),
              controller: _noteController,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedMood == null ? null : _saveMood,
                child: const Text('Save Mood'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildMoodButton(String emoji, String mood) {
    final isSelected = _selectedMood == mood;
    return ChoiceChip(
      label: Text('$emoji $mood'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMood = selected ? mood : null;
        });
      },
    );
  }

  Widget _buildMoodHistory(List<MoodLog> moodLogs) {
    if (moodLogs.isEmpty) {
      return Center(
        child: Text(
          'No mood logs yet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: moodLogs.length,
          itemBuilder: (context, index) {
            final log = moodLogs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(_getMoodEmoji(log.mood)),
                ),
                title: Text(log.mood),
                subtitle: log.note.isNotEmpty
                    ? Text(log.note)
                    : null,
                trailing: Text(
                  _formatDate(log.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
          },
        ),
      ],
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      case 'bored':
        return '😴';
      case 'thoughtful':
        return '🤔';
      default:
        return '😐';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;

    final moodLog = MoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: widget.bookId,
      mood: _selectedMood!,
      note: _noteController.text.trim(),
    );

    try {
      await _firebaseService.addMoodLog(widget.bookId, moodLog);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully')),
        );
        setState(() {
          _selectedMood = null;
          _noteController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
      }
    }
  }
} 