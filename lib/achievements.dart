import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themeprovider.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  // Original achievement data structure with added descriptions
  final List<Map<String, dynamic>> achievements = [
    {
      'title': '5 Days Streak',
      'completed': true,
      'description': 'Check in for 5 consecutive days to unlock this achievement',
      'progress': '5/5 days completed'
    },
    {
      'title': '7 Days Streak',
      'completed': true,
      'description': 'Maintain your mindfulness practice for a full week',
      'progress': '7/7 days completed'
    },
    {
      'title': '3 Weeks Streak',
      'completed': false,
      'description': 'Build a strong habit with 21 days of consistent check-ins',
      'progress': '10/21 days completed'
    },
    {
      'title': '1 Month Streak',
      'completed': false,
      'description': 'Commit to your mental health for 30 straight days',
      'progress': '10/30 days completed'
    },
    {
      'title': 'First Check-in',
      'completed': true,
      'description': 'You took the first step in your mindfulness journey!',
      'progress': 'Completed!'
    },
    {
      'title': '5 Check-ins',
      'completed': true,
      'description': 'Halfway to building your first streak!',
      'progress': '5/5 check-ins completed'
    },
    {
      'title': '10 Check-ins',
      'completed': true,
      'description': 'Double digits! You\'re building a strong practice',
      'progress': '10/10 check-ins completed'
    },
  ];

  void _showAchievementDetails(BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement['title'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement['description'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[800],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: achievement['completed'] 
                    ? Colors.green.withOpacity(isDarkMode ? 0.3 : 0.2)
                    : Colors.blue.withOpacity(isDarkMode ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  achievement['progress'],
                  style: TextStyle(
                    color: achievement['completed'] 
                      ? Colors.green[isDarkMode ? 300 : 700]
                      : Colors.blue[isDarkMode ? 300 : 700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: isDarkMode ? Colors.deepPurple[300] : Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.deepPurple;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return GestureDetector(
              onTap: () => _showAchievementDetails(context, achievement),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _AchievementCard(
                  title: achievement['title'],
                  completed: achievement['completed'],
                  color: achievement['completed'] 
                      ? primaryColor[400]! 
                      : primaryColor[200]!,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final bool completed;
  final Color color;

  const _AchievementCard({
    required this.title,
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    completed ? Icons.check : Icons.hourglass_top,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              completed ? Icons.star : Icons.info_outline,
              color: completed ? Colors.amber : Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}