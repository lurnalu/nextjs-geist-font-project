import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';
import '../services/brevo_service.dart';
import '../services/notification_service.dart';
import '../services/config_service.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Appointment> appointments = [];
  late NotificationService _notificationService;
  late DatabaseService _databaseService;
  late BrevoService _brevoService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _databaseService = DatabaseService();
      _brevoService = BrevoService();
      
      await ConfigService().init();
      await _brevoService.init();
      await _databaseService.init();
      
      _notificationService = NotificationService(_brevoService);
      
      await _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing services: $e')),
      );
    }
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);
      final appointmentMaps = await _databaseService.getAppointments();
      setState(() {
        appointments = appointmentMaps.map((map) {
          return Appointment(
            id: map['id'],
            patientId: map['patientId'],
            appointmentDate: DateTime.parse(map['appointmentDate']),
            doctorName: map['doctorName'],
            notes: map['notes'],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    }
  }

  Future<void> _sendReminder(Appointment appointment) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sending reminder...')),
      );

      final patientMaps = await _databaseService.getPatients();
      final patient = patientMaps.firstWhere(
        (p) => p['id'] == appointment.patientId,
        orElse: () => throw Exception('Patient not found'),
      );

      final success = await _notificationService.sendAppointmentReminder(
        email: patient['email'],
        phoneNumber: patient['phone'],
        patientName: '${patient['firstName']} ${patient['lastName']}',
        appointmentDate: appointment.appointmentDate.toLocal().toString().split(' ')[0],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Reminder sent successfully' : 'Failed to send reminder'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text('Patient ID: ${appointment.patientId}'),
                        subtitle: Text(
                          '${appointment.appointmentDate.toLocal().toString().split(' ')[0]} - Dr. ${appointment.doctorName}',
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
                              onPressed: () => _showDeleteConfirmation(appointment),
                            ),
                            IconButton(
                              icon: Icon(Icons.notifications_active),
                              tooltip: 'Send Reminder',
                              onPressed: () => _sendReminder(appointment),
                            ),
                          ],
                        ),
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

  Future<void> _showDeleteConfirmation(Appointment appointment) async {
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
              _deleteAppointment(appointment.id!);
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

  Future<void> _showAppointmentForm({Appointment? appointment}) async {
    final _formKey = GlobalKey<FormState>();
    int patientId = appointment?.patientId ?? 0;
    DateTime? appointmentDate = appointment?.appointmentDate;
    String doctorName = appointment?.doctorName ?? '';
    String notes = appointment?.notes ?? '';

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
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Appointment Date',
                    hintText: appointmentDate != null
                        ? appointmentDate.toLocal().toString().split(' ')[0]
                        : 'Select Date',
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: appointmentDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        appointmentDate = picked;
                      });
                    }
                  },
                  validator: (value) =>
                      appointmentDate == null ? 'Required' : null,
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
                  _addAppointment(Appointment(
                    patientId: patientId,
                    appointmentDate: appointmentDate!,
                    doctorName: doctorName,
                    notes: notes,
                  ));
                } else {
                  _updateAppointment(Appointment(
                    id: appointment.id,
                    patientId: patientId,
                    appointmentDate: appointmentDate!,
                    doctorName: doctorName,
                    notes: notes,
                  ));
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

  Future<void> _addAppointment(Appointment appointment) async {
    try {
      final map = appointment.toMap();
      final id = await _databaseService.insertAppointment(map);
      setState(() {
        appointments.add(Appointment(
          id: id,
          patientId: appointment.patientId,
          appointmentDate: appointment.appointmentDate,
          doctorName: appointment.doctorName,
          notes: appointment.notes,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding appointment: $e')),
      );
    }
  }

  Future<void> _updateAppointment(Appointment appointment) async {
    try {
      await _databaseService.updateAppointment(appointment.id!, appointment.toMap());
      setState(() {
        final index = appointments.indexWhere((a) => a.id == appointment.id);
        if (index != -1) {
          appointments[index] = appointment;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating appointment: $e')),
      );
    }
  }

  Future<void> _deleteAppointment(int id) async {
    try {
      await _databaseService.deleteAppointment(id);
      setState(() {
        appointments.removeWhere((a) => a.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting appointment: $e')),
      );
    }
  }
}
