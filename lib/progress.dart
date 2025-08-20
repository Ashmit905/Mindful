import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'themeprovider.dart';
import 'main.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavigationBarExample();
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  Map<String, double> dataMap = {};
  bool _isLoading = true;
  String _quote = "Fetching quote...";

  @override
  void initState() {
    super.initState();
    _fetchEmotionData();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final response = await http.post(
          Uri.parse("https://yousufmo0.pythonanywhere.com/api/quote"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data["message"];
        });
      } else {
        setState(() {
          _quote = "Failed to fetch quote.";
        });
      }
    } catch (e) {
      setState(() {
        _quote = "Error: $e";
      });
    }
  }

  Future<void> _fetchEmotionData() async {
    setState(() {
      _isLoading = true;
    });
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? "";
    try {
      final response = await Supabase.instance.client
          .from('Check_In_Page')
          .select('EMOTIONS')
          .eq('USERID', userId);

      if (response == null) {
        print('Error fetching emotion data: ${response}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> emotionLists = response;
      final Map<String, int> emotionCounts = {};
      int totalEmotions = 0;

      for (final emotionList in emotionLists) {
        if (emotionList != null && emotionList['EMOTIONS'] != null) {
          String emotionsString = emotionList['EMOTIONS'] as String;
          emotionsString = emotionsString
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '');
          final emotions = emotionsString.split(',');
          for (final emotion in emotions) {
            final trimmedEmotion = emotion.trim();
            emotionCounts[trimmedEmotion] =
                (emotionCounts[trimmedEmotion] ?? 0) + 1;
            totalEmotions++;
          }
        }
      }

      setState(() {
        dataMap =
            emotionCounts.map((key, value) => MapEntry(key, value.toDouble()));
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLegend() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: dataMap.entries.map((entry) {
        final index = dataMap.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.primaries[index % Colors.primaries.length],
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} (${entry.value.toInt()})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.deepPurple : Colors.white,
        title: Text("Progress", style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Streak Container
            Container(
              height: 150,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Text(
                      'Streaks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40.0,
                          color: Colors.yellow[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '10 day streak!',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.blue[800],
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mood Graph Container
            Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Mood Distribution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : dataMap.isNotEmpty
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.spaceAround,
                                        maxY: dataMap.values.reduce(
                                                (a, b) => a > b ? a : b) *
                                            1.2,
                                        titlesData: FlTitlesData(
                                          show: true,
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 4.0),
                                                  child: Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              },
                                              interval: 1,
                                              reservedSize: 28,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          getDrawingHorizontalLine: (value) => FlLine(
                                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                            strokeWidth: 1,
                                          ),
                                          checkToShowHorizontalLine: (value) => value % 1 == 0,
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                              final emotion = dataMap.keys.toList()[group.x.toInt()];
                                              return BarTooltipItem(
                                                '$emotion\n${rod.toY.toInt()}',
                                                TextStyle(
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [],
                                              );
                                            },
                                          ),
                                        ),
                                        barGroups: dataMap.entries.map((entry) {
                                          final index = dataMap.keys.toList().indexOf(entry.key);
                                          return BarChartGroupData(
                                            x: index,
                                            barsSpace: 4,
                                            barRods: [
                                              BarChartRodData(
                                                toY: entry.value,
                                                color: Colors.primaries[index % Colors.primaries.length],
                                                width: 22,
                                                borderRadius: BorderRadius.zero,
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLegend(),
                                ],
                              )
                            : Center(
                                child: Text(
                                  'No emotion data available',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),

            // Milestones Container
            Container(
              height: 150,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Text(
                      'Latest Milestones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 40.0,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '5 achievements unlocked!',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.blue[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quote Container
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.deepPurple : Colors.blue[600],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Inspiration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _quote,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}