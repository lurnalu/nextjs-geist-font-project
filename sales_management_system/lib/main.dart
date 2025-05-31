import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_management_system/services/auth_service.dart';
import 'package:sales_management_system/services/theme_service.dart';
import 'package:sales_management_system/screens/auth/login_screen.dart';
import 'package:sales_management_system/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper().database;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Clinic Sales Management',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: FutureBuilder<bool>(
            future: Provider.of<AuthService>(context, listen: false).initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
