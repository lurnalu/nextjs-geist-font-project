import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _db.getClinicStats(_startDate, _endDate);
      setState(() => _stats = stats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
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
                  _buildDateRangeCard(),
                  SizedBox(height: 16),
                  _buildOverviewStats(),
                  SizedBox(height: 16),
                  _buildAppointmentStats(),
                  SizedBox(height: 16),
                  _buildFinancialStats(),
                  SizedBox(height: 16),
                  _buildPatientStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.date_range),
        title: Text('Report Period'),
        subtitle: Text(
          '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
        ),
        trailing: TextButton(
          onPressed: _selectDateRange,
          child: Text('Change'),
        ),
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Patients',
                  _stats['totalPatients']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Total Appointments',
                  _stats['totalAppointments']?.toString() ?? '0',
                  Icons.calendar_today,
                  Colors.green,
                ),
                _buildStatItem(
                  'Revenue',
                  _currencyFormat.format(_stats['totalRevenue'] ?? 0),
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Completed',
                  _stats['completedAppointments']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Pending',
                  _stats['pendingAppointments']?.toString() ?? '0',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Cancelled',
                  _stats['cancelledAppointments']?.toString() ?? '0',
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Revenue',
                  _currencyFormat.format(_stats['totalRevenue'] ?? 0),
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatItem(
                  'Pending Payments',
                  _currencyFormat.format(_stats['pendingPayments'] ?? 0),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Average Bill',
                  _currencyFormat.format(_stats['averageBillAmount'] ?? 0),
                  Icons.analytics,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'New Patients',
                  _stats['newPatients']?.toString() ?? '0',
                  Icons.person_add,
                  Colors.green,
                ),
                _buildStatItem(
                  'Return Visits',
                  _stats['returnVisits']?.toString() ?? '0',
                  Icons.repeat,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Avg. Visit Duration',
                  '${_stats['averageVisitDuration']?.toString() ?? '0'} min',
                  Icons.timer,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
