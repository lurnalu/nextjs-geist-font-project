import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'admin/user_management_screen.dart';
import 'reports_screen.dart';
import 'marketing_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = AuthService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _activeUsers = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Get overall clinic stats
      final today = DateTime.now();
      final monthStart = DateTime(today.year, today.month, 1);
      final stats = await _db.getClinicStats(monthStart, today);

      // TODO: Implement getActiveUsers in DatabaseService
      // _activeUsers = await _db.getActiveUsers();

      setState(() => _stats = stats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSystemSettings() {
    // TODO: Implement system settings dialog
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Database Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Create Backup'),
              onTap: () {
                // TODO: Implement backup creation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.restore),
              title: Text('Restore Backup'),
              onTap: () {
                // TODO: Implement backup restoration
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
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
        title: Text('Admin Dashboard'),
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
                    'System Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildSystemStats(),
                  SizedBox(height: 24),
                  Text(
                    'Active Users',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildActiveUsers(),
                  SizedBox(height: 24),
                  Text(
                    'Administrative Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildAdminActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildSystemStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Revenue',
          _currencyFormat.format(_stats['totalRevenue'] ?? 0),
          Icons.monetization_on,
          Colors.green,
        ),
        _buildStatCard(
          'Total Patients',
          _stats['totalPatients']?.toString() ?? '0',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Users',
          _activeUsers.length.toString(),
          Icons.person,
          Colors.orange,
        ),
        _buildStatCard(
          'Appointments',
          _stats['totalAppointments']?.toString() ?? '0',
          Icons.calendar_today,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildActiveUsers() {
    if (_activeUsers.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No active users'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _activeUsers.length,
      itemBuilder: (context, index) {
        final user = _activeUsers[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('${user['firstName']} ${user['lastName']}'),
            subtitle: Text('Role: ${user['role']}'),
            trailing: Text(
              'Last active: ${DateFormat('MMM d, y HH:mm').format(
                DateTime.parse(user['lastLogin'] ?? ''),
              )}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          'User Management',
          Icons.manage_accounts,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserManagementScreen()),
          ),
        ),
        _buildActionCard(
          'Reports & Analytics',
          Icons.analytics,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportsScreen()),
          ),
        ),
        _buildActionCard(
          'Marketing',
          Icons.campaign,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MarketingScreen()),
          ),
        ),
        _buildActionCard(
          'System Settings',
          Icons.settings,
          Colors.purple,
          _showSystemSettings,
        ),
        _buildActionCard(
          'Database Backup',
          Icons.backup,
          Colors.teal,
          _showBackupOptions,
        ),
        _buildActionCard(
          'Audit Logs',
          Icons.history,
          Colors.indigo,
          () {
            // TODO: Implement audit logs screen
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
