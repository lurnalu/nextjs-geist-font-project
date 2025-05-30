import 'package:flutter/material.dart';
import '../services/database_service.dart';

class PatientListScreen extends StatefulWidget {
  final bool isSelecting;

  const PatientListScreen({
    Key? key,
    this.isSelecting = false,
  }) : super(key: key);

  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final loadedPatients = await _databaseService.getPatients();
      setState(() => _patients = loadedPatients);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patients: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final query = _searchQuery.toLowerCase();
    return _patients.where((patient) {
      final firstName = patient['firstName'].toString().toLowerCase();
      final lastName = patient['lastName'].toString().toLowerCase();
      final phone = patient['phoneNumber'].toString().toLowerCase();
      return firstName.contains(query) ||
          lastName.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  Future<void> _showAddEditPatientDialog([Map<String, dynamic>? existingPatient]) async {
    final _formKey = GlobalKey<FormState>();
    String firstName = existingPatient?['firstName'] ?? '';
    String lastName = existingPatient?['lastName'] ?? '';
    String dateOfBirth = existingPatient?['dateOfBirth'] ?? '';
    String gender = existingPatient?['gender'] ?? 'MALE';
    String phoneNumber = existingPatient?['phoneNumber'] ?? '';
    String email = existingPatient?['email'] ?? '';
    String address = existingPatient?['address'] ?? '';
    String emergencyContact = existingPatient?['emergencyContact'] ?? '';
    String emergencyPhone = existingPatient?['emergencyPhone'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingPatient == null ? 'Add Patient' : 'Edit Patient'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: firstName,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => firstName = value ?? '',
                ),
                TextFormField(
                  initialValue: lastName,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => lastName = value ?? '',
                ),
                TextFormField(
                  initialValue: dateOfBirth,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => dateOfBirth = value ?? '',
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  items: ['MALE', 'FEMALE', 'OTHER']
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (value) => gender = value ?? 'MALE',
                ),
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(labelText: 'Email'),
                  onSaved: (value) => email = value ?? '',
                ),
                TextFormField(
                  initialValue: address,
                  decoration: InputDecoration(labelText: 'Address'),
                  onSaved: (value) => address = value ?? '',
                ),
                TextFormField(
                  initialValue: emergencyContact,
                  decoration: InputDecoration(labelText: 'Emergency Contact'),
                  onSaved: (value) => emergencyContact = value ?? '',
                ),
                TextFormField(
                  initialValue: emergencyPhone,
                  decoration: InputDecoration(labelText: 'Emergency Phone'),
                  onSaved: (value) => emergencyPhone = value ?? '',
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
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                try {
                  final patientData = {
                    'firstName': firstName,
                    'lastName': lastName,
                    'dateOfBirth': dateOfBirth,
                    'gender': gender,
                    'phoneNumber': phoneNumber,
                    'email': email,
                    'address': address,
                    'emergencyContact': emergencyContact,
                    'emergencyPhone': emergencyPhone,
                  };

                  if (existingPatient != null) {
                    // Make sure we have a valid ID for updating
                    final id = existingPatient['id'];
                    if (id != null) {
                      await _databaseService.updatePatient(id, patientData);
                    } else {
                      throw Exception('Invalid patient ID');
                    }
                  } else {
                    await _databaseService.insertPatient(patientData);
                  }
                  
                  Navigator.pop(context);
                  _loadPatients();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving patient: $e')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Select Patient' : 'Patients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Patients',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(child: Text('No patients found'))
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return ListTile(
                            title: Text(
                                '${patient['firstName']} ${patient['lastName']}'),
                            subtitle: Text(patient['phoneNumber']),
                            trailing: widget.isSelecting
                                ? Icon(Icons.chevron_right)
                                : PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit'),
                                        ),
                                        onTap: () => Future.delayed(
                                          Duration(seconds: 0),
                                          () => _showAddEditPatientDialog(patient),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading:
                                              Icon(Icons.delete, color: Colors.red),
                                          title: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text(
                                                  'Are you sure you want to delete this patient?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                      context, false),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm ?? false) {
                                            try {
                                              final id = patient['id'];
                                              if (id != null) {
                                                await _databaseService
                                                    .deletePatient(id);
                                                _loadPatients();
                                              } else {
                                                throw Exception('Invalid patient ID');
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error deleting patient: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                            onTap: widget.isSelecting
                                ? () => Navigator.pop(context, patient)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.isSelecting
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddEditPatientDialog(),
              child: Icon(Icons.add),
              tooltip: 'Add Patient',
            ),
    );
  }
}
