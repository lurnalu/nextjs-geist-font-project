import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const ProgressTrackingScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  late TabController _tabController;
  List<Map<String, dynamic>> _progressNotes = [];
  List<Map<String, dynamic>> _vitalsHistory = [];
  List<Map<String, dynamic>> _treatmentMilestones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatientProgress();
  }

  Future<void> _loadPatientProgress() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement loading of progress data from database
      await Future.delayed(Duration(seconds: 1)); // Simulate loading
      setState(() {
        _progressNotes = [];
        _vitalsHistory = [];
        _treatmentMilestones = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading progress data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddProgressNoteDialog() {
    final _formKey = GlobalKey<FormState>();
    String note = '';
    String outcome = 'IMPROVED';
    String painLevel = '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Progress Note'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Progress Note',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => note = value,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: outcome,
                  decoration: InputDecoration(labelText: 'Outcome'),
                  items: ['IMPROVED', 'UNCHANGED', 'DETERIORATED']
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                  onChanged: (value) => outcome = value ?? 'IMPROVED',
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: painLevel,
                  decoration: InputDecoration(labelText: 'Pain Level'),
                  items: List.generate(11, (i) => i.toString())
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) => painLevel = value ?? '0',
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
                // TODO: Save progress note
                Navigator.pop(context);
                _loadPatientProgress();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog() {
    final _formKey = GlobalKey<FormState>();
    String milestone = '';
    String status = 'PENDING';
    DateTime targetDate = DateTime.now().add(Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Treatment Milestone'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Milestone Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => milestone = value,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => status = value ?? 'PENDING',
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      targetDate = date;
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Target Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('yyyy-MM-dd').format(targetDate)),
                  ),
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
                // TODO: Save milestone
                Navigator.pop(context);
                _loadPatientProgress();
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
        title: Text('Progress Tracking - ${widget.patientName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Progress Notes'),
            Tab(text: 'Vitals History'),
            Tab(text: 'Milestones'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProgressNotesTab(),
                _buildVitalsHistoryTab(),
                _buildMilestonesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tabController.index) {
            case 1:
              _showAddProgressNoteDialog();
              break;
            case 3:
              _showAddMilestoneDialog();
              break;
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Entry',
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treatment Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Text('Start Date: ${DateFormat('MMM d, y').format(DateTime.now())}'),
                  Text('Latest Visit: ${DateFormat('MMM d, y').format(DateTime.now())}'),
                  Text('Total Visits: 0'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Text('Current Status: Improving'),
                  Text('Pain Level Trend: Decreasing'),
                  Text('Compliance: Good'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Text('Next Appointment: ${DateFormat('MMM d, y').format(DateTime.now())}'),
                  Text('Pending Tests: None'),
                  Text('Treatment Phase: Initial'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNotesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _progressNotes.length,
      itemBuilder: (context, index) {
        final note = _progressNotes[index];
        return Card(
          child: ListTile(
            title: Text(note['note']),
            subtitle: Text(
              'Outcome: ${note['outcome']}\n'
              'Pain Level: ${note['painLevel']}\n'
              'Date: ${DateFormat('MMM d, y').format(DateTime.parse(note['date']))}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildVitalsHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // TODO: Add charts for vitals trends
          Text('Vitals history charts will be displayed here'),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _vitalsHistory.length,
            itemBuilder: (context, index) {
              final vitals = _vitalsHistory[index];
              return Card(
                child: ListTile(
                  title: Text(
                    'Date: ${DateFormat('MMM d, y').format(DateTime.parse(vitals['date']))}',
                  ),
                  subtitle: Text(
                    'BP: ${vitals['bloodPressure']}\n'
                    'HR: ${vitals['heartRate']}\n'
                    'Temp: ${vitals['temperature']}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _treatmentMilestones.length,
      itemBuilder: (context, index) {
        final milestone = _treatmentMilestones[index];
        return Card(
          child: ListTile(
            title: Text(milestone['description']),
            subtitle: Text(
              'Status: ${milestone['status']}\n'
              'Target Date: ${DateFormat('MMM d, y').format(DateTime.parse(milestone['targetDate']))}',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                  onTap: () {
                    // TODO: Implement milestone editing
                  },
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.check),
                    title: Text('Mark Complete'),
                  ),
                  onTap: () {
                    // TODO: Implement milestone completion
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
