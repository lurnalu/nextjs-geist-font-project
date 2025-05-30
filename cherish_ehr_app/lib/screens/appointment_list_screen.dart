import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);
      final loadedAppointments = await _databaseService.getAppointments();
      if (mounted) {
        setState(() {
          appointments = loadedAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(child: Text('No appointments found'))
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final appointmentDate = appointment['appointmentDate'] != null 
                        ? DateTime.tryParse(appointment['appointmentDate'])
                        : null;
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text('Patient ID: ${appointment['patientId']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${appointmentDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                            ),
                            Text('Doctor: ${appointment['doctorName'] ?? 'N/A'}'),
                            if (appointment['notes']?.isNotEmpty ?? false)
                              Text('Notes: ${appointment['notes']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showAppointmentForm(appointment: appointment),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(appointment['id']),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppointmentForm(),
        child: Icon(Icons.add),
        tooltip: 'Add Appointment',
      ),
    );
  }

  Future<void> _showDeleteConfirmation(int id) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Appointment'),
        content: Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(id);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppointmentForm({Map<String, dynamic>? appointment}) async {
    final _formKey = GlobalKey<FormState>();
    int patientId = appointment?['patientId'] ?? 0;
    String appointmentDate = appointment?['appointmentDate'] ?? '';
    String doctorName = appointment?['doctorName'] ?? '';
    String notes = appointment?['notes'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment == null ? 'Add Appointment' : 'Edit Appointment'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: patientId == 0 ? '' : patientId.toString(),
                  decoration: InputDecoration(labelText: 'Patient ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => patientId = int.tryParse(value ?? '') ?? 0,
                ),
                TextFormField(
                  initialValue: appointmentDate,
                  decoration: InputDecoration(
                    labelText: 'Appointment Date (YYYY-MM-DD)',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => appointmentDate = value ?? '',
                ),
                TextFormField(
                  initialValue: doctorName,
                  decoration: InputDecoration(labelText: 'Doctor Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => doctorName = value ?? '',
                ),
                TextFormField(
                  initialValue: notes,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  onSaved: (value) => notes = value ?? '',
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
                if (appointment == null) {
                  _addAppointment({
                    'patientId': patientId,
                    'appointmentDate': appointmentDate,
                    'doctorName': doctorName,
                    'notes': notes,
                  });
                } else {
                  _updateAppointment(appointment['id'], {
                    'patientId': patientId,
                    'appointmentDate': appointmentDate,
                    'doctorName': doctorName,
                    'notes': notes,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(appointment == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAppointment(Map<String, dynamic> appointment) async {
    try {
      await _databaseService.insertAppointment(appointment);
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding appointment: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointment(int id, Map<String, dynamic> appointment) async {
    try {
      await _databaseService.updateAppointment(id, appointment);
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating appointment: $e')),
        );
      }
    }
  }

  Future<void> _deleteAppointment(int id) async {
    try {
      await _databaseService.deleteAppointment(id);
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting appointment: $e')),
        );
      }
    }
  }
}
