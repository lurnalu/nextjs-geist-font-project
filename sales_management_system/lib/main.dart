import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_management_system/services/theme_service.dart';
import 'package:sales_management_system/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
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
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
            ),
          ),
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginScreen(),
        );
      },
    );
  }
}
