import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'patient_list_screen.dart';
import 'appointment_list_screen.dart';
import '../services/auth_service.dart';

class ReceptionistDashboard extends StatefulWidget {
  @override
  _ReceptionistDashboardState createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Get today's appointments
      final today = DateTime.now();
      final stats = await _db.getClinicStats(
        DateTime(today.year, today.month, today.day),
        DateTime(today.year, today.month, today.day, 23, 59, 59),
      );
      setState(() => _stats = stats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVisitorRegistration() {
    final _formKey = GlobalKey<FormState>();
    String visitorName = '';
    String purpose = '';
    String phoneNumber = '';
    String personToMeet = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register Visitor'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Visitor Name'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => visitorName = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Purpose of Visit'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => purpose = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Person to Meet'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => personToMeet = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                // TODO: Save visitor information to database
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Visitor registered successfully')),
                );
              }
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  void _showQuickAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentListScreen(),
      ),
    );
  }

  void _showEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Contacts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text('Ambulance'),
              subtitle: Text('999'),
              trailing: IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {
                  // TODO: Implement phone call
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.blue),
              title: Text('On-Call Doctor'),
              subtitle: Text('+254700000000'),
              trailing: IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {
                  // TODO: Implement phone call
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.green),
              title: Text('Security'),
              subtitle: Text('+254700000001'),
              trailing: IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {
                  // TODO: Implement phone call
                },
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receptionist Dashboard'),
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
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildStatsGrid(),
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
          'Today\'s Appointments',
          _stats['totalAppointments']?.toString() ?? '0',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending Check-ins',
          _stats['pendingAppointments']?.toString() ?? '0',
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Completed Visits',
          _stats['completedAppointments']?.toString() ?? '0',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'New Patients Today',
          _stats['newPatients']?.toString() ?? '0',
          Icons.person_add,
          Colors.purple,
        ),
      ],
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
          'Register Patient',
          Icons.person_add,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PatientListScreen()),
          ),
        ),
        _buildActionCard(
          'Schedule Appointment',
          Icons.calendar_today,
          Colors.green,
          _showQuickAppointment,
        ),
        _buildActionCard(
          'Register Visitor',
          Icons.how_to_reg,
          Colors.orange,
          _showVisitorRegistration,
        ),
        _buildActionCard(
          'Emergency Contacts',
          Icons.emergency,
          Colors.red,
          _showEmergencyContact,
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
