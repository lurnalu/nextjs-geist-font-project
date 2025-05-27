import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(CherishEHRApp());
}

class CherishEHRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cherish Orthopaedic Centre',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Use the logo image from assets
        Image.asset(
          'assets/logo.png',
          height: 120,
        ),
        SizedBox(height: 16),
        Text(
          'Cherish Orthopaedic Centre',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Nanyuki, Kenya',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      key: Key('email'),
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (value) => email = value ?? '',
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: Key('password'),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onSaved: (value) => password = value ?? '',
    );
  }

  Widget _buildConfirmPasswordField() {
    if (isLogin) return SizedBox.shrink();
    return TextFormField(
      key: Key('confirmPassword'),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (!isLogin) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != password) {
            return 'Passwords do not match';
          }
        }
        return null;
      },
      onSaved: (value) => confirmPassword = value ?? '',
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: Implement authentication logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin ? 'Logging in...' : 'Signing up...'),
        ),
      );
      // Navigate to home screen after login/signup
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                SizedBox(height: 32),
                _buildEmailField(),
                SizedBox(height: 16),
                _buildPasswordField(),
                SizedBox(height: 16),
                _buildConfirmPasswordField(),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isLogin ? 'Login' : 'Sign Up'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: toggleForm,
                  child: Text(
                    isLogin
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Login',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
