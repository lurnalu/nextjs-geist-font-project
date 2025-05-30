import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PrescriptionScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, List<String>>> _medications = [
    {'name': 'Paracetamol', 'dosages': ['500mg', '650mg', '1000mg']},
    {'name': 'Ibuprofen', 'dosages': ['200mg', '400mg', '600mg']},
    {'name': 'Amoxicillin', 'dosages': ['250mg', '500mg']},
  ].map((m) => Map<String, List<String>>.from({
        'name': [m['name'] as String],
        'dosages': (m['dosages'] as List).map((d) => d.toString()).toList(),
      })).toList();

  String _selectedMedication = '';
  String _selectedDosage = '';

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
    if (_medications.isNotEmpty) {
      _selectedMedication = _medications[0]['name']![0];
      _selectedDosage = _medications[0]['dosages']![0];
    }
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement getPrescriptions in DatabaseService
      // _prescriptions = await _db.getPrescriptions(widget.patientId);
      setState(() => _prescriptions = []); // Temporary empty list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading prescriptions: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddPrescriptionDialog() {
    final _formKey = GlobalKey<FormState>();
    String frequency = '1-0-1';
    String duration = '7';
    String instructions = '';
    bool beforeFood = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Prescription'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMedication,
                  decoration: InputDecoration(labelText: 'Medication'),
                  items: _medications
                      .map((med) => DropdownMenuItem<String>(
                            value: med['name']![0],
                            child: Text(med['name']![0]),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMedication = value;
                        _selectedDosage = _medications
                            .firstWhere((med) => med['name']![0] == value)['dosages']![0];
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDosage,
                  decoration: InputDecoration(labelText: 'Dosage'),
                  items: _medications
                      .firstWhere((med) => med['name']![0] == _selectedMedication)['dosages']!
                      .map<DropdownMenuItem<String>>((dosage) => DropdownMenuItem<String>(
                            value: dosage,
                            child: Text(dosage),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDosage = value);
                    }
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Frequency (e.g., 1-0-1)',
                    hintText: 'Morning-Afternoon-Night',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => frequency = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Duration (days)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => duration = value,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Take Before Food'),
                  value: beforeFood,
                  onChanged: (value) => setState(() => beforeFood = value ?? true),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Special Instructions',
                  ),
                  maxLines: 2,
                  onChanged: (value) => instructions = value,
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
                // TODO: Save prescription
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Prescription added')),
                );
                _loadPrescriptions();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions - ${widget.patientName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              // TODO: Print prescription
            },
            tooltip: 'Print Prescription',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCurrentMedications(),
                Expanded(
                  child: _buildPrescriptionHistory(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPrescriptionDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Prescription',
      ),
    );
  }

  Widget _buildCurrentMedications() {
    final currentMeds = _prescriptions
        .where((p) => DateTime.parse(p['endDate']).isAfter(DateTime.now()))
        .toList();

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Medications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            if (currentMeds.isEmpty)
              Text('No current medications')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: currentMeds.length,
                itemBuilder: (context, index) {
                  final prescription = currentMeds[index];
                  return ListTile(
                    title: Text(prescription['medication']),
                    subtitle: Text(
                      '${prescription['dosage']} - ${prescription['frequency']}\n'
                      'Until: ${DateFormat('MMM d, y').format(DateTime.parse(prescription['endDate']))}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Implement prescription deletion
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionHistory() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prescription History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            if (_prescriptions.isEmpty)
              Text('No prescription history')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = _prescriptions[index];
                    return Card(
                      child: ListTile(
                        title: Text(prescription['medication']),
                        subtitle: Text(
                          '${prescription['dosage']} - ${prescription['frequency']}\n'
                          'Prescribed: ${DateFormat('MMM d, y').format(DateTime.parse(prescription['prescribedDate']))}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            // TODO: Copy prescription to new
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
