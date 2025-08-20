import 'package:flutter/material.dart';
import 'package:mindful/register.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'themeprovider.dart';
import 'themes.dart';
import 'progress.dart';
import 'achievements.dart';
import 'checkin.dart';
import 'insights.dart';


void main() {
  Future<void> initializedb() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'SUPABASE_URL',
      anonKey: 'API_KEY',
    );
  }

  initializedb();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null ? MyHomePage(title: 'Home Page') : WelcomeScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '';
  String greeting = 'Hello there';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      setState(() {
        greeting = 'Good morning';
      });
    } else if (hour < 17) {
      setState(() {
        greeting = 'Good afternoon';
      });
    } else {
      setState(() {
        greeting = 'Good evening';
      });
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .single();
        
        if (response != null && response['full_name'] != null) {
          setState(() {
            userName = response['full_name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, 
            vertical: 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mindful',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting${userName.isNotEmpty ? ', $userName' : ''}!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How are you feeling today?',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: [
                    _ColoredFeatureButton(
                      icon: Icons.bar_chart,
                      title: 'Progress',
                      color: Colors.blueAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressPage()),
                      ),
                    ),
                    _ColoredFeatureButton(
                      icon: Icons.edit_note,
                      title: 'Check-in',
                      color: Colors.greenAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckInPage()),
                      ),
                    ),
                    _ColoredFeatureButton(
                      icon: Icons.auto_awesome,
                      title: 'AI Strategies',
                      color: Colors.purpleAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InsightsPage()), // Changed to InsightsPage
                      ),
                    ),
                    _ColoredFeatureButton(
                      icon: Icons.emoji_events,
                      title: 'Achievements',
                      color: Colors.orangeAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AchievementsPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.brightness_4, size: 28),
              color: Colors.white,
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu, size: 28),
              color: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: theme.dialogBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      'Menu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'Log out',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => WelcomeScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoredFeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const _ColoredFeatureButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}