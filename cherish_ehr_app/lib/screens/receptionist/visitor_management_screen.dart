import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class VisitorManagementScreen extends StatefulWidget {
  @override
  _VisitorManagementScreenState createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _visitors = [];

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement getVisitors in DatabaseService
      // _visitors = await _db.getVisitors();
      setState(() => _visitors = []); // Temporary empty list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading visitors: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddVisitorDialog([Map<String, dynamic>? visitor]) async {
    final _formKey = GlobalKey<FormState>();
    String name = visitor?['name'] ?? '';
    String purpose = visitor?['purpose'] ?? '';
    String phone = visitor?['phone'] ?? '';
    String personToMeet = visitor?['personToMeet'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(visitor == null ? 'Add Visitor' : 'Edit Visitor'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Visitor Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                TextFormField(
                  initialValue: purpose,
                  decoration: InputDecoration(labelText: 'Purpose of Visit'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => purpose = value ?? '',
                ),
                TextFormField(
                  initialValue: phone,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => phone = value ?? '',
                ),
                TextFormField(
                  initialValue: personToMeet,
                  decoration: InputDecoration(labelText: 'Person to Meet'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => personToMeet = value ?? '',
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
                  final visitorData = {
                    'name': name,
                    'purpose': purpose,
                    'phone': phone,
                    'personToMeet': personToMeet,
                  };

                  if (visitor == null) {
                    // TODO: Implement insertVisitor in DatabaseService
                    // await _db.insertVisitor(visitorData);
                  } else {
                    // TODO: Implement updateVisitor in DatabaseService
                    // await _db.updateVisitor(visitor['id'], visitorData);
                  }
                  Navigator.pop(context);
                  _loadVisitors();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving visitor: $e')),
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

  Future<void> _deleteVisitor(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this visitor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        // TODO: Implement deleteVisitor in DatabaseService
        // await _db.deleteVisitor(id);
        _loadVisitors();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting visitor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visitor Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _visitors.isEmpty
              ? Center(child: Text('No visitors found'))
              : ListView.builder(
                  itemCount: _visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = _visitors[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(visitor['name']),
                        subtitle: Text(
                            'Purpose: ${visitor['purpose']}\nPerson to Meet: ${visitor['personToMeet']}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              ),
                              onTap: () => Future.delayed(
                                Duration(seconds: 0),
                                () => _showAddVisitorDialog(visitor),
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              onTap: () => Future.delayed(
                                Duration(seconds: 0),
                                () => _deleteVisitor(visitor['id']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVisitorDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Visitor',
      ),
    );
  }
}
