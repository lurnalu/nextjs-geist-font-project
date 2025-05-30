import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class AppointmentReminderScreen extends StatefulWidget {
  @override
  _AppointmentReminderScreenState createState() =>
      _AppointmentReminderScreenState();
}

class _AppointmentReminderScreenState extends State<AppointmentReminderScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  late TabController _tabController;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _sentReminders = [];
  List<Map<String, dynamic>> _missedAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement appointment loading from DatabaseService
      // _upcomingAppointments = await _db.getUpcomingAppointments();
      // _sentReminders = await _db.getSentReminders();
      // _missedAppointments = await _db.getMissedAppointments();
      setState(() {
        _upcomingAppointments = [];
        _sentReminders = [];
        _missedAppointments = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReminder(Map<String, dynamic> appointment) async {
    try {
      // TODO: Implement reminder sending
      // await _db.sendAppointmentReminder(appointment['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder sent successfully')),
      );
      _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reminder: $e')),
      );
    }
  }

  Future<void> _sendBulkReminders() async {
    try {
      // TODO: Implement bulk reminder sending
      // await _db.sendBulkReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bulk reminders sent successfully')),
      );
      _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reminders: $e')),
      );
    }
  }

  void _showReminderSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reminder Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('SMS Reminders'),
                value: true,
                onChanged: (value) {
                  // TODO: Implement reminder settings
                },
              ),
              SwitchListTile(
                title: Text('Email Reminders'),
                value: true,
                onChanged: (value) {
                  // TODO: Implement reminder settings
                },
              ),
              ListTile(
                title: Text('Reminder Time'),
                subtitle: Text('24 hours before appointment'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement reminder timing settings
                },
              ),
              ListTile(
                title: Text('Reminder Template'),
                subtitle: Text('Edit message template'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement template editing
                },
              ),
            ],
          ),
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
        title: Text('Appointment Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showReminderSettingsDialog,
            tooltip: 'Reminder Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming'),
            Tab(text: 'Sent'),
            Tab(text: 'Missed'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                _buildSentTab(),
                _buildMissedTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _sendBulkReminders,
              icon: Icon(Icons.send),
              label: Text('Send All Reminders'),
            )
          : null,
    );
  }

  Widget _buildUpcomingTab() {
    return Column(
      children: [
        _buildReminderStats(),
        Expanded(
          child: _upcomingAppointments.isEmpty
              ? Center(child: Text('No upcoming appointments'))
              : ListView.builder(
                  itemCount: _upcomingAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _upcomingAppointments[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                            '${appointment['patientName']} - Dr. ${appointment['doctorName']}'),
                        subtitle: Text(
                          'Date: ${DateFormat('MMM d, y HH:mm').format(DateTime.parse(appointment['dateTime']))}\n'
                          'Status: ${appointment['reminderStatus']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () => _sendReminder(appointment),
                          tooltip: 'Send Reminder',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSentTab() {
    return ListView.builder(
      itemCount: _sentReminders.length,
      itemBuilder: (context, index) {
        final reminder = _sentReminders[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(reminder['patientName']),
            subtitle: Text(
              'Sent: ${DateFormat('MMM d, y HH:mm').format(DateTime.parse(reminder['sentDate']))}\n'
              'Method: ${reminder['method']}',
            ),
            trailing: Icon(
              reminder['delivered'] ? Icons.check_circle : Icons.error,
              color: reminder['delivered'] ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissedTab() {
    return ListView.builder(
      itemCount: _missedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _missedAppointments[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(appointment['patientName']),
            subtitle: Text(
              'Scheduled: ${DateFormat('MMM d, y HH:mm').format(DateTime.parse(appointment['dateTime']))}\n'
              'Doctor: Dr. ${appointment['doctorName']}',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Call Patient'),
                  ),
                  onTap: () {
                    // TODO: Implement call patient
                  },
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Reschedule'),
                  ),
                  onTap: () {
                    // TODO: Implement reschedule
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderStats() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Today\'s\nAppointments',
              _upcomingAppointments
                  .where((a) =>
                      DateTime.parse(a['dateTime']).day == DateTime.now().day)
                  .length
                  .toString(),
              Colors.blue,
            ),
            _buildStatItem(
              'Pending\nReminders',
              _upcomingAppointments
                  .where((a) => a['reminderStatus'] == 'PENDING')
                  .length
                  .toString(),
              Colors.orange,
            ),
            _buildStatItem(
              'Sent\nToday',
              _sentReminders
                  .where((r) =>
                      DateTime.parse(r['sentDate']).day == DateTime.now().day)
                  .length
                  .toString(),
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
