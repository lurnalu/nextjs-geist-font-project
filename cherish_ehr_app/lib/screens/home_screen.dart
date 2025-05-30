import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';
import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
import 'accountant_dashboard.dart';
import 'receptionist_dashboard.dart';

class HomeScreen extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final userRole = currentUser?.role;

    // Redirect users to their role-specific dashboards
    switch (userRole) {
      case UserRole.admin:
        return AdminDashboard();
      case UserRole.doctor:
        return DoctorDashboard();
      case UserRole.accountant:
        return AccountantDashboard();
      case UserRole.receptionist:
        return ReceptionistDashboard();
      default:
        // Fallback screen for unknown roles or errors
        return Scaffold(
          appBar: AppBar(
            title: Text('Cherish Orthopaedic Centre'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Invalid User Role',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Please contact your administrator',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await _authService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
