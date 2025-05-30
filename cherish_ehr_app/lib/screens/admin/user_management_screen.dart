import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _authService = AuthService();
  List<User> _users = [];
  bool _isLoading = true;
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _authService.getUsers(role: _selectedRole);
      setState(() => _users = users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddUserDialog() async {
    final _formKey = GlobalKey<FormState>();
    String email = '';
    String firstName = '';
    String lastName = '';
    String phoneNumber = '';
    String password = '';
    UserRole role = UserRole.receptionist;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => firstName = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => lastName = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                  onSaved: (value) => email = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value ?? '',
                ),
                DropdownButtonFormField<UserRole>(
                  decoration: InputDecoration(labelText: 'Role'),
                  value: role,
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName),
                          ))
                      .toList(),
                  onChanged: (value) => role = value!,
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
                  await _authService.register(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    role: role,
                  );
                  Navigator.pop(context);
                  _loadUsers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('Add User'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      await _authService.updateUserStatus(user.id!, !user.isActive);
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Role Filter
          Padding(
            padding: EdgeInsets.all(16),
            child: DropdownButtonFormField<UserRole?>(
              decoration: InputDecoration(
                labelText: 'Filter by Role',
                border: OutlineInputBorder(),
              ),
              value: _selectedRole,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Roles'),
                ),
                ...UserRole.values.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    )),
              ],
              onChanged: (role) {
                setState(() => _selectedRole = role);
                _loadUsers();
              },
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              user.firstName[0] + user.lastName[0],
                            ),
                          ),
                          title: Text(user.fullName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              Text(
                                user.role.displayName,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: user.isActive,
                                onChanged: (_) => _toggleUserStatus(user),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Implement edit user
                                },
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add),
        tooltip: 'Add User',
      ),
    );
  }
}
