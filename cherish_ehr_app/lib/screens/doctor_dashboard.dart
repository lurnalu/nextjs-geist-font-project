import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'doctor/consultation_screen.dart';
import 'doctor/prescription_screen.dart';
import 'doctor/progress_tracking_screen.dart';
import 'package:intl/intl.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _todaysAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final today = DateTime.now();
      final stats = await _db.getClinicStats(
        DateTime(today.year, today.month, today.day),
        DateTime(today.year, today.month, today.day, 23, 59, 59),
      );
      
      // Get today's appointments for the logged-in doctor
      final currentUser = _authService.currentUser;
      if (currentUser != null && mounted) {
        final appointments = await _db.getAppointments();
        setState(() {
          _stats = stats;
          _todaysAppointments = appointments.where((apt) {
            return apt['doctorId'] == currentUser.id && 
                   apt['status'] == 'SCHEDULED';
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToScreen(Widget screen) {
    if (!mounted) return;
    
    if (_todaysAppointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No patients scheduled for today')),
      );
      return;
    }

    final appointment = _todaysAppointments.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    ).then((_) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(),
                    SizedBox(height: 24),
                    Text(
                      'Today\'s Appointments',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _buildAppointments(),
                    SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Today\'s Patients',
          _todaysAppointments.length.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending',
          _todaysAppointments.where((a) => a['status'] == 'WAITING').length.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Completed',
          _todaysAppointments.where((a) => a['status'] == 'COMPLETED').length.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Emergency',
          _todaysAppointments.where((a) => a['isEmergency'] == true).length.toString(),
          Icons.emergency,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildAppointments() {
    if (_todaysAppointments.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No appointments scheduled for today')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _todaysAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _todaysAppointments[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: appointment['isEmergency'] == true
                  ? Colors.red
                  : Colors.blue,
              child: Text('${index + 1}'),
            ),
            title: Text(
              '${appointment['patientFirstName']} ${appointment['patientLastName']}',
            ),
            subtitle: Text(
              'Time: ${DateFormat('HH:mm').format(DateTime.parse(appointment['dateTime']))}\n'
              'Status: ${appointment['status']}',
            ),
            trailing: ElevatedButton(
              onPressed: () => _navigateToScreen(
                ConsultationScreen(
                  patientId: appointment['patientId'],
                  patientName: '${appointment['patientFirstName']} ${appointment['patientLastName']}',
                ),
              ),
              child: Text('Start Consultation'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          'Patient Consultation',
          Icons.medical_services,
          Colors.blue,
          () {
            if (_todaysAppointments.isEmpty) return;
            _navigateToScreen(
              ConsultationScreen(
                patientId: _todaysAppointments.first['patientId'],
                patientName: '${_todaysAppointments.first['patientFirstName']} ${_todaysAppointments.first['patientLastName']}',
              ),
            );
          },
        ),
        _buildActionCard(
          'Prescriptions',
          Icons.medication,
          Colors.green,
          () {
            if (_todaysAppointments.isEmpty) return;
            _navigateToScreen(
              PrescriptionScreen(
                patientId: _todaysAppointments.first['patientId'],
                patientName: '${_todaysAppointments.first['patientFirstName']} ${_todaysAppointments.first['patientLastName']}',
              ),
            );
          },
        ),
        _buildActionCard(
          'Progress Tracking',
          Icons.trending_up,
          Colors.orange,
          () {
            if (_todaysAppointments.isEmpty) return;
            _navigateToScreen(
              ProgressTrackingScreen(
                patientId: _todaysAppointments.first['patientId'],
                patientName: '${_todaysAppointments.first['patientFirstName']} ${_todaysAppointments.first['patientLastName']}',
              ),
            );
          },
        ),
        _buildActionCard(
          'Emergency Cases',
          Icons.emergency,
          Colors.red,
          () {
            // TODO: Show emergency cases
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
