import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final db = DatabaseService();
    await db.init();
    final patientMaps = await db.getPatients();
    setState(() {
      patients = patientMaps.map((map) {
        return Patient(
          id: map['id'],
          firstName: map['firstName'],
          lastName: map['lastName'],
          phone: map['phone'],
          email: map['email'],
          dateOfBirth: DateTime.parse(map['dateOfBirth']),
        );
      }).toList();
    });
  }

  Future<void> _showPatientForm({Patient? patient}) async {
    final _formKey = GlobalKey<FormState>();
    String firstName = patient?.firstName ?? '';
    String lastName = patient?.lastName ?? '';
    String phone = patient?.phone ?? '';
    String email = patient?.email ?? '';
    DateTime? dateOfBirth = patient?.dateOfBirth;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(patient == null ? 'Add Patient' : 'Edit Patient'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: firstName,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => firstName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: lastName,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => lastName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: phone,
                    decoration: InputDecoration(labelText: 'Phone'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => phone = value ?? '',
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => email = value ?? '',
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: dateOfBirth != null
                          ? dateOfBirth.toLocal().toString().split(' ')[0]
                          : 'Select Date',
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dateOfBirth ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          dateOfBirth = picked;
                        });
                      }
                    },
                    validator: (value) =>
                        dateOfBirth == null ? 'Required' : null,
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
                  if (patient == null) {
                    _addPatient(Patient(
                      firstName: firstName,
                      lastName: lastName,
                      phone: phone,
                      email: email,
                      dateOfBirth: dateOfBirth!,
                    ));
                  } else {
                    _updatePatient(Patient(
                      id: patient.id,
                      firstName: firstName,
                      lastName: lastName,
                      phone: phone,
                      email: email,
                      dateOfBirth: dateOfBirth!,
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(patient == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPatient(Patient patient) async {
    // TODO: Add patient to database
    setState(() {
      patients.add(patient);
    });
  }

  Future<void> _updatePatient(Patient patient) async {
    // TODO: Update patient in database
    setState(() {
      final index = patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        patients[index] = patient;
      }
    });
  }

  Future<void> _deletePatient(int id) async {
    // TODO: Delete patient from database
    setState(() {
      patients.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            title: Text('${patient.firstName} ${patient.lastName}'),
            subtitle: Text(patient.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showPatientForm(patient: patient),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePatient(patient.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPatientForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
