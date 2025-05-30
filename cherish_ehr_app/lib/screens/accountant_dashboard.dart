import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'accountant/expense_management_screen.dart';
import 'accountant/financial_reports_screen.dart';
import 'accountant/invoice_management_screen.dart';
import 'package:intl/intl.dart';

class AccountantDashboard extends StatefulWidget {
  @override
  _AccountantDashboardState createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  final DatabaseService _db = DatabaseService();
  final AuthService _authService = AuthService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
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
      final today = DateTime.now();
      final stats = await _db.getClinicStats(
        DateTime(today.year, today.month, 1),
        today,
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

  void _showUserProfile() {
    final currentUser = _authService.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('${currentUser?.firstName} ${currentUser?.lastName}'),
              subtitle: Text('Name'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(currentUser?.email ?? ''),
              subtitle: Text('Email'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(currentUser?.phoneNumber ?? ''),
              subtitle: Text('Phone'),
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
        title: Text('Accountant Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _showUserProfile,
            tooltip: 'Profile',
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
                    'Monthly Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildFinancialStats(),
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

  Widget _buildFinancialStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Monthly Revenue',
          _currencyFormat.format(_stats['totalRevenue'] ?? 0),
          Icons.monetization_on,
          Colors.green,
        ),
        _buildStatCard(
          'Monthly Expenses',
          _currencyFormat.format(_stats['totalExpenses'] ?? 0),
          Icons.money_off,
          Colors.red,
        ),
        _buildStatCard(
          'Pending Payments',
          _currencyFormat.format(_stats['pendingPayments'] ?? 0),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Appointments',
          _stats['totalAppointments']?.toString() ?? '0',
          Icons.calendar_today,
          Colors.blue,
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
          'Invoice Management',
          Icons.receipt_long,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InvoiceManagementScreen()),
          ),
        ),
        _buildActionCard(
          'Expense Management',
          Icons.money_off,
          Colors.red,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExpenseManagementScreen()),
          ),
        ),
        _buildActionCard(
          'Financial Reports',
          Icons.analytics,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FinancialReportsScreen()),
          ),
        ),
        _buildActionCard(
          'Payment Processing',
          Icons.payment,
          Colors.purple,
          () {
            // TODO: Implement payment processing screen
          },
        ),
        _buildActionCard(
          'Insurance Claims',
          Icons.health_and_safety,
          Colors.orange,
          () {
            // TODO: Implement insurance claims screen
          },
        ),
        _buildActionCard(
          'Tax Reports',
          Icons.description,
          Colors.teal,
          () {
            // TODO: Implement tax reports screen
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
