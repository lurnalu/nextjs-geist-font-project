import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class WaitingRoomScreen extends StatefulWidget {
  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _waitingPatients = [];
  Map<String, List<Map<String, dynamic>>> _doctorQueues = {};

  @override
  void initState() {
    super.initState();
    _loadWaitingRoom();
  }

  Future<void> _loadWaitingRoom() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement waiting room data loading from DatabaseService
      // _waitingPatients = await _db.getWaitingPatients();
      // final doctors = await _db.getDoctors();
      // for (var doctor in doctors) {
      //   _doctorQueues[doctor['id']] = await _db.getDoctorQueue(doctor['id']);
      // }
      setState(() {
        _waitingPatients = [];
        _doctorQueues = {};
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading waiting room data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check-In Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search Patient',
                  prefixIcon: Icon(Icons.search),
                ),
                // TODO: Implement patient search
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Select Doctor'),
                items: _doctorQueues.keys.map((doctorId) {
                  return DropdownMenuItem(
                    value: doctorId,
                    child: Text('Dr. Smith'), // Replace with actual doctor name
                  );
                }).toList(),
                onChanged: (value) {
                  // TODO: Handle doctor selection
                },
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Emergency Case'),
                value: false,
                onChanged: (value) {
                  // TODO: Handle emergency flag
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement patient check-in
              Navigator.pop(context);
            },
            child: Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _showQueueManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Queue Management'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Auto-assign patients'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement auto-assign setting
                  },
                ),
              ),
              ListTile(
                title: Text('Maximum waiting time'),
                subtitle: Text('60 minutes'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement waiting time setting
                },
              ),
              ListTile(
                title: Text('Emergency slot interval'),
                subtitle: Text('Every 3 patients'),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // TODO: Implement emergency slot setting
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
        title: Text('Waiting Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showQueueManagementDialog,
            tooltip: 'Queue Settings',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWaitingRoomStats(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildWaitingList(),
                      ),
                      VerticalDivider(),
                      Expanded(
                        flex: 3,
                        child: _buildDoctorQueues(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCheckInDialog,
        icon: Icon(Icons.add),
        label: Text('Check In Patient'),
      ),
    );
  }

  Widget _buildWaitingRoomStats() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Waiting',
              _waitingPatients.length.toString(),
              Colors.blue,
            ),
            _buildStatItem(
              'Average Wait',
              '25 min',
              Colors.orange,
            ),
            _buildStatItem(
              'Emergency Cases',
              _waitingPatients
                  .where((p) => p['isEmergency'] == true)
                  .length
                  .toString(),
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingList() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Waiting List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _waitingPatients.length,
              itemBuilder: (context, index) {
                final patient = _waitingPatients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: patient['isEmergency'] == true
                        ? Colors.red
                        : Colors.blue,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(patient['name']),
                  subtitle: Text(
                    'Waiting since: ${DateFormat('HH:mm').format(DateTime.parse(patient['checkInTime']))}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Assign Doctor'),
                        ),
                        onTap: () {
                          // TODO: Implement doctor assignment
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.cancel),
                          title: Text('Cancel'),
                        ),
                        onTap: () {
                          // TODO: Implement check-out
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorQueues() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Doctor Queues',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _doctorQueues.isEmpty
                ? Center(child: Text('No active doctor queues'))
                : ListView.builder(
                    itemCount: _doctorQueues.length,
                    itemBuilder: (context, index) {
                      final doctorId = _doctorQueues.keys.elementAt(index);
                      final queue = _doctorQueues[doctorId] ?? [];
                      return ExpansionTile(
                        title: Text('Dr. Smith'), // Replace with actual doctor name
                        subtitle: Text('${queue.length} patients in queue'),
                        children: queue.map((patient) {
                          return ListTile(
                            title: Text(patient['name']),
                            subtitle: Text(
                              'Waiting: ${DateFormat('HH:mm').format(DateTime.parse(patient['checkInTime']))}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.call_next),
                              onPressed: () {
                                // TODO: Implement call next patient
                              },
                              tooltip: 'Call Patient',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
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
        ),
      ],
    );
  }
}
