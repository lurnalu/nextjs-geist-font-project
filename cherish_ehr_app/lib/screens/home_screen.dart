import 'package:flutter/material.dart';
import 'patient_list_screen.dart';
import 'appointment_list_screen.dart';
import 'marketing_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cherish Orthopaedic Centre'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFeatureCard(
              context,
              title: 'Patients',
              icon: Icons.people,
              description: 'Manage patient records and information',
              screen: PatientListScreen(),
            ),
            SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Appointments',
              icon: Icons.calendar_today,
              description: 'Schedule and manage appointments',
              screen: AppointmentListScreen(),
            ),
            SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Marketing',
              icon: Icons.campaign,
              description: 'Send promotional emails and SMS campaigns',
              screen: MarketingScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Widget screen,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                  SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
