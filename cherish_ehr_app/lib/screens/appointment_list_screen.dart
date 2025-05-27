import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final db = DatabaseService();
    await db.init();
    final appointmentMaps = await db.getAppointments();
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
    });
  }

  Future<void> _showAppointmentForm({Appointment? appointment}) async {
    final _formKey = GlobalKey<FormState>();
    int patientId = appointment?.patientId ?? 0;
    DateTime? appointmentDate = appointment?.appointmentDate;
    String doctorName = appointment?.doctorName ?? '';
    String notes = appointment?.notes ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> _addAppointment(Appointment appointment) async {
    // TODO: Add appointment to database
    setState(() {
      appointments.add(appointment);
    });
  }

  Future<void> _updateAppointment(Appointment appointment) async {
    // TODO: Update appointment in database
    setState(() {
      final index = appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        appointments[index] = appointment;
      }
    });
  }

  Future<void> _deleteAppointment(int id) async {
    // TODO: Delete appointment from database
    setState(() {
      appointments.removeWhere((a) => a.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return ListTile(
            title: Text('Patient ID: ${appointment.patientId}'),
            subtitle: Text(
                '${appointment.appointmentDate.toLocal().toString().split(' ')[0]} - Dr. ${appointment.doctorName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showAppointmentForm(appointment: appointment),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAppointment(appointment.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppointmentForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
