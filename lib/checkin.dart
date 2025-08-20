import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final supabase = Supabase.instance.client;
  List<String> selectedEmotions = [];
  final notesController = TextEditingController();
  double moodValue = 8.0;
  bool _isSubmitting = false;

  static const List<String> emotions = [
    "Happy", "Motivated", "Confident", "Relaxed",
    "Sad", "Anxious", "Overwhelmed", "Tired",
  ];

  Future<void> _submitCheckIn() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Validate user is logged in
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 2. Prepare data with proper types
      final checkInData = {
        'USERID': user.id,
        'ENTRY_DT': DateTime.now().toIso8601String(),
        'FEELING': moodValue.round(), // Convert to integer
        'EMOTIONS': selectedEmotions,
        'NOTES': notesController.text,
      };

      debugPrint('Submitting: $checkInData');

      // 3. Insert with proper error handling for newer Supabase client
      final response = await supabase
          .from('Check_In_Page')
          .insert(checkInData)
          .select()
          .single();

      // If we get here, the insert was successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      _resetForm();

    } on PostgrestException catch (e) {
      // Handle Supabase-specific errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Database error: ${e.message}');
    } catch (e) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Submission error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      moodValue = 7.0;
      selectedEmotions.clear();
      notesController.clear();
    });
  }

  void _toggleEmotion(String emotion) {
    setState(() {
      selectedEmotions.contains(emotion)
          ? selectedEmotions.remove(emotion)
          : selectedEmotions.add(emotion);
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Slider
            Text(
              'How are you feeling? ${moodValue.round()}/10',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: moodValue,
              min: 0,
              max: 10,
              divisions: 10,
              label: moodValue.round().toString(),
              onChanged: (value) => setState(() => moodValue = value),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.onSurface.withOpacity(0.3),
            ),

            // Emotions Selection
            const SizedBox(height: 24),
            Text('Select emotions:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emotions.map((emotion) => FilterChip(
                label: Text(emotion),
                selected: selectedEmotions.contains(emotion),
                onSelected: (_) => _toggleEmotion(emotion),
                selectedColor: theme.colorScheme.primaryContainer,
                backgroundColor: theme.colorScheme.surfaceVariant,
                labelStyle: TextStyle(
                  color: selectedEmotions.contains(emotion)
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              )).toList(),
            ),

            // Notes Field
            const SizedBox(height: 24),
            Text('Notes:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Describe how you feel...',
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
              ),
            ),

            // Submit Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'SUBMIT CHECK-IN',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}