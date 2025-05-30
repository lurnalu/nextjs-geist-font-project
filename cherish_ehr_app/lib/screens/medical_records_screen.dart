import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import '../services/database_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const MedicalRecordsScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await _db.getMedicalRecords(widget.patientId);
      setState(() => _records = records);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading records: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditRecordDialog([Map<String, dynamic>? record]) async {
    final _formKey = GlobalKey<FormState>();
    String diagnosis = record?['diagnosis'] ?? '';
    String treatment = record?['treatment'] ?? '';
    String prescription = record?['prescription'] ?? '';
    String notes = record?['notes'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record == null ? 'Add Medical Record' : 'Edit Medical Record'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: diagnosis,
                  decoration: InputDecoration(labelText: 'Diagnosis'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => diagnosis = value ?? '',
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: treatment,
                  decoration: InputDecoration(labelText: 'Treatment'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => treatment = value ?? '',
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: prescription,
                  decoration: InputDecoration(labelText: 'Prescription'),
                  onSaved: (value) => prescription = value ?? '',
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: notes,
                  decoration: InputDecoration(labelText: 'Notes'),
                  onSaved: (value) => notes = value ?? '',
                  maxLines: 3,
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
                  if (record == null) {
                    await _db.insertMedicalRecord({
                      'patientId': widget.patientId,
                      'doctorId': 1, // Replace with actual logged-in doctor ID
                      'diagnosis': diagnosis,
                      'treatment': treatment,
                      'prescription': prescription,
                      'notes': notes,
                    });
                  } else {
                    await _db.updateMedicalRecord(
                      record['id'],
                      {
                        'diagnosis': diagnosis,
                        'treatment': treatment,
                        'prescription': prescription,
                        'notes': notes,
                      },
                    );
                  }
                  Navigator.pop(context);
                  _loadRecords();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving record: $e')),
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
        title: Text('Medical Records - ${widget.patientName}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(
                  child: Text('No medical records found'),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          'Visit on ${record['createdAt']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          record['diagnosis'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSection('Diagnosis', record['diagnosis']),
                                _buildSection('Treatment', record['treatment']),
                                if (record['prescription']?.isNotEmpty ?? false)
                                  _buildSection(
                                      'Prescription', record['prescription']),
                                if (record['notes']?.isNotEmpty ?? false)
                                  _buildSection('Notes', record['notes']),
                                ButtonBar(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          _showAddEditRecordDialog(record),
                                      child: Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Confirm Delete'),
                                            content: Text(
                                                'Are you sure you want to delete this record?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: Text(
                                                  'Delete',
                                                  style:
                                                      TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm ?? false) {
                                          try {
                                            await _db.deleteMedicalRecord(
                                                record['id']);
                                            _loadRecords();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting record: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRecordDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Medical Record',
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}
