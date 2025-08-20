import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Mindful',
              style: TextStyle(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40.0),
            _buildButton(context, 'Login', Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }),
            SizedBox(height: 20.0),
            _buildButton(context, 'Create Your Account', Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final supabase = Supabase.instance.client;

    return Scaffold(
      body: _buildAuthForm(
        context,
        title: 'Login',
        buttonText: 'Continue',
        onPressed: () async {
          try {
            final response = await supabase.auth.signInWithPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
            print(response.session);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: "Hello")),
            );
          } catch (e) {
            print('Unexpected error: $e');
            _showErrorDialog(context, "Login Failed", "Please Try Again");
          }
        },
        bottomWidget: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: Text("Don't have an account? Sign up", style: TextStyle(color: Colors.blueAccent)),
        ),
        emailController: emailController,
        passwordController: passwordController,
      ),
    );
  }
}

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController fullNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final supabase = Supabase.instance.client;

    return Scaffold(
      body: _buildAuthForm(
        context,
        title: 'Create Account',
        buttonText: 'Sign Up',
        onPressed: () async {
          if (passwordController.text.trim().length < 6) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Password Too Short'),
                content: Text('Password must be at least 6 characters long.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          try {
            final response = await supabase.auth.signUp(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
              data: {'email_confirm': false},
            );

            if (response.user != null) {
              await supabase.from('users').insert({
                'id': response.user!.id,
                'full_name': fullNameController.text,
                'email': emailController.text,
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: "Hello")),
              );
            }
          } catch (e) {
            print('Sign up failed: $e');
            _showErrorDialog(context, "Sign Up Failed", "Please try again.");
          }
        },
        bottomWidget: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Text("Already have an account? Log in", style: TextStyle(color: Colors.blueAccent)),
        ),
        emailController: emailController,
        passwordController: passwordController,
        additionalTextField: _buildTextField('Full Name', controller: fullNameController),
      ),
    );
  }
}

Widget _buildAuthForm(
    BuildContext context, {
      required String title,
      required String buttonText,
      required VoidCallback onPressed,
      required Widget bottomWidget,
      required TextEditingController emailController,
      required TextEditingController passwordController,
      Widget? additionalTextField,
    }) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.lightBlue.shade50],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          if (additionalTextField != null) additionalTextField,
          SizedBox(height: 15),
          _buildTextField('Email', controller: emailController),
          SizedBox(height: 15),
          _buildTextField('Password', controller: passwordController, obscureText: true),
          SizedBox(height: 15),
          _buildButton(context, buttonText, Colors.blueAccent, onPressed),
          SizedBox(height: 20),
          bottomWidget,
        ],
      ),
    ),
  );
}

Widget _buildTextField(String label, {bool obscureText = false, TextEditingController? controller}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
    style: TextStyle(
      color: Colors.black, // Ensures text is visible
      fontSize: 16,
    ),
    keyboardType: label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
  );
}

Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
  );
}