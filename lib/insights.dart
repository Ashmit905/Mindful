import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  bool _isLoading = true;
  List<ClinicalInsight> _insights = [];
  List<ClinicalRecommendation> _recommendations = [];
  String _therapeuticNote = '';
  double _avgMood = 0;
  String _primaryEmotion = '';
  int _streak = 0;
  int _checkInCount = 0;

  @override
  void initState() {
    super.initState();
    _loadClinicalData();
  }

  Future<void> _loadClinicalData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('Check_In_Page')
          .select('FEELING, EMOTIONS, ENTRY_DT')
          .eq('USERID', user.id)
          .order('ENTRY_DT', ascending: false);

      if (response.isEmpty) {
        setState(() {
          _therapeuticNote = 'Complete your first check-in to unlock insights';
          _isLoading = false;
        });
        return;
      }

      // Process clinical data
      _processClinicalData(response);

      // Get AI analysis
      await _fetchClinicalAnalysis();

    } catch (e) {
      print('Clinical Data Error: $e');
      _setFallbackContent();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processClinicalData(List<dynamic> records) {
    // Mood analysis
    final moods = records
        .where((r) => r['FEELING'] != null)
        .map((r) => r['FEELING'] is int ? r['FEELING'].toDouble() : double.parse(r['FEELING'].toString()))
        .toList();
    _avgMood = moods.isNotEmpty ? moods.reduce((a, b) => a + b) / moods.length : 0;

    // Emotion analysis
    final emotionCounts = <String, int>{};
    for (final record in records) {
      if (record['EMOTIONS'] != null) {
        final emotions = record['EMOTIONS'].toString()
            .replaceAll(RegExp(r'[\[\]"]'), '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty);

        for (final emotion in emotions) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }
    }
    _primaryEmotion = emotionCounts.isNotEmpty
        ? emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'Not enough data';

    // Engagement metrics
    _checkInCount = records.length;
    _streak = records.length > 7 ? 7 : records.length; // Simplified streak
  }

  Future<void> _fetchClinicalAnalysis() async {
    try {
      final response = await http.post(
        Uri.parse("https://yousufmo0.pythonanywhere.com/api/insights"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'average_mood': _avgMood,
          'common_emotion': _primaryEmotion,
          'emotion_counts': _getTopEmotions(),
          'checkin_count': _checkInCount,
          'streak_days': _streak,
          'checkin_dates': _getCheckinDates(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _insights = (data['insights'] as List)
              .map((i) => ClinicalInsight.fromString(i.toString()))
              .toList();

          _recommendations = (data['suggestions'] as List)
              .map((s) => ClinicalRecommendation.fromString(s.toString()))
              .toList();

          _therapeuticNote = data['note'] ?? 'Your mental health matters';
        });
      } else {
        throw Exception('Clinical analysis failed');
      }
    } catch (e) {
      print('Clinical Analysis Error: $e');
      _setFallbackContent();
    }
  }

  Map<String, int> _getTopEmotions() {
    return {'Sample': 1};
  }

  List<String> _getCheckinDates() {
    return [];
  }

  void _setFallbackContent() {
    setState(() {
      _insights = [
        ClinicalInsight(
          observation: 'Regular check-ins detected',
          interpretation: 'Shows commitment to self-awareness',
        )
      ];

      _recommendations = [
        ClinicalRecommendation(
          action: 'Continue daily check-ins',
          rationale: 'Consistency improves mental health tracking',
          priority: 'high',
        )
      ];

      _therapeuticNote = 'Professional analysis will appear here';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = Colors.deepPurple;
    final cardColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Insights'),
        elevation: 0,
        backgroundColor: isDarkMode ? primaryColor : Colors.deepPurple[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingState(isDarkMode)
          : _buildClinicalDashboard(
              theme,
              isDarkMode,
              cardColor,
              textColor,
              secondaryTextColor,
              primaryColor,
            ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Analyzing your mental health patterns',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalDashboard(
    ThemeData theme,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildClinicalSummaryCard(theme, isDarkMode, cardColor, textColor, primaryColor),
          const SizedBox(height: 20),
          if (_therapeuticNote.isNotEmpty) 
            _buildTherapeuticNoteCard(theme, isDarkMode, cardColor, textColor, primaryColor),
          const SizedBox(height: 20),
          _buildClinicalInsightsCard(theme, isDarkMode, cardColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          _buildRecommendationsCard(theme, isDarkMode, cardColor, textColor, secondaryTextColor),
        ],
      ),
    );
  }

  Widget _buildClinicalSummaryCard(
    ThemeData theme,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'YOUR CLINICAL SUMMARY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDarkMode ? Colors.deepPurple[300] : Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricTile('Mood', _avgMood.toStringAsFixed(1), isDarkMode, primaryColor),
                _buildMetricTile('Streak', '$_streak days', isDarkMode, primaryColor),
                _buildMetricTile('Primary Emotion', _primaryEmotion, isDarkMode, primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, bool isDarkMode, Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? primaryColor.withOpacity(0.3)
                : Colors.deepPurple[100],
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.deepPurple[800],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.1,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTherapeuticNoteCard(
    ThemeData theme,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Card(
      color: isDarkMode 
          ? primaryColor.withOpacity(0.2)
          : Colors.deepPurple[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.medical_services, 
              color: isDarkMode ? Colors.deepPurple[300] : primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _therapeuticNote,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInsightsCard(
    ThemeData theme,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLINICAL OBSERVATIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDarkMode ? Colors.deepPurple[300] : Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            ..._insights.map((insight) => Column(
              children: [
                _buildInsightTile(insight, isDarkMode),
                if (_insights.last != insight)
                  Divider(
                    height: 24,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(ClinicalInsight insight, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insight.observation,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.deepPurple[300] : Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          insight.interpretation,
          style: TextStyle(
            height: 1.4,
            color: isDarkMode ? Colors.white70 : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(
    ThemeData theme,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERSONALIZED RECOMMENDATIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDarkMode ? Colors.deepPurple[300] : Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            ..._recommendations.map((rec) => Column(
              children: [
                _buildRecommendationTile(rec, isDarkMode),
                if (_recommendations.last != rec)
                  Divider(
                    height: 24,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(ClinicalRecommendation rec, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_information,
              color: _getPriorityColor(rec.priority, isDarkMode),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rec.action,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(rec.priority, isDarkMode),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            rec.rationale,
            style: TextStyle(
              height: 1.4,
              color: isDarkMode ? Colors.white70 : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority, bool isDarkMode) {
    switch (priority.toLowerCase()) {
      case 'high': 
        return isDarkMode ? Colors.red[300]! : Colors.red;
      case 'medium': 
        return isDarkMode ? Colors.orange[300]! : Colors.orange;
      default: 
        return isDarkMode ? Colors.green[300]! : Colors.green;
    }
  }
}

class ClinicalInsight {
  final String observation;
  final String interpretation;

  ClinicalInsight({
    required this.observation,
    required this.interpretation,
  });

  factory ClinicalInsight.fromString(String insight) {
    final parts = insight.split('\n→ ');
    return ClinicalInsight(
      observation: parts.first,
      interpretation: parts.length > 1 ? parts.last : '',
    );
  }
}

class ClinicalRecommendation {
  final String action;
  final String rationale;
  final String priority;

  ClinicalRecommendation({
    required this.action,
    required this.rationale,
    required this.priority,
  });

  factory ClinicalRecommendation.fromString(String recommendation) {
    final lines = recommendation.split('\n');
    final priorityMatch = RegExp(r'\((.*?)\)').firstMatch(lines.first);
    return ClinicalRecommendation(
      action: lines.first.replaceAll(RegExp(r'\(.*?\)'), '').trim(),
      rationale: lines.length > 1 ? lines.last.replaceFirst('- ', '') : '',
      priority: priorityMatch?.group(1)?.toLowerCase() ?? 'medium',
    );
  }
}