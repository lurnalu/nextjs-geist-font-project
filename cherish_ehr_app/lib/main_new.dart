import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/config_service.dart';
import 'services/brevo_service.dart';
import 'models/user.dart';
import 'models/user_role.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final authService = AuthService();
  final databaseService = DatabaseService();
  
  await ConfigService().init();
  await databaseService.init();
  await authService.init();
  await BrevoService().init();
  
  runApp(CherishEHRApp());
}

class CherishEHRApp extends StatefulWidget {
  @override
  _CherishEHRAppState createState() => _CherishEHRAppState();
}

class _CherishEHRAppState extends State<CherishEHRApp> {
  final _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      setState(() => _currentUser = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cherish Orthopaedic Centre',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
      home: _currentUser == null ? LoginScreen() : HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => LoginScreen());
        }
        if (settings.name == '/forgot-password') {
          return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
        }
        if (settings.name?.startsWith('/reset-password/') ?? false) {
          final token = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(resetToken: token),
          );
        }
        if (settings.name == '/admin/users') {
          // Check if user is admin
          if (_currentUser?.role != UserRole.admin) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Access Denied'),
                ),
              ),
            );
          }
          return MaterialPageRoute(builder: (_) => UserManagementScreen());
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (_) => HomeScreen());
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
