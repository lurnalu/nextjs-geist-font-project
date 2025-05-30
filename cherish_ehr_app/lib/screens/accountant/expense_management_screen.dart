import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class ExpenseManagementScreen extends StatefulWidget {
  @override
  _ExpenseManagementScreenState createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  bool _isLoading = true;
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement getExpenses in DatabaseService
      // _expenses = await _db.getExpenses();
      setState(() => _expenses = []); // Temporary empty list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expenses: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditExpenseDialog([Map<String, dynamic>? expense]) async {
    final _formKey = GlobalKey<FormState>();
    String description = expense?['description'] ?? '';
    double amount = expense?['amount']?.toDouble() ?? 0.0;
    String category = expense?['category'] ?? 'SUPPLIES';
    String? notes = expense?['notes'];
    DateTime date = expense?['date'] != null
        ? DateTime.parse(expense!['date'])
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => description = value ?? '',
                ),
                TextFormField(
                  initialValue: amount > 0 ? amount.toString() : '',
                  decoration: InputDecoration(
                    labelText: 'Amount (KES)',
                    prefixText: 'KES ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final amount = double.tryParse(value!);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value ?? '0'),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: [
                    'SUPPLIES',
                    'EQUIPMENT',
                    'UTILITIES',
                    'SALARIES',
                    'MAINTENANCE',
                    'OTHER'
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => category = value ?? 'SUPPLIES',
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => date = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Date'),
                    child: Text(DateFormat('yyyy-MM-dd').format(date)),
                  ),
                ),
                TextFormField(
                  initialValue: notes,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  onSaved: (value) => notes = value,
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
                  final expenseData = {
                    'description': description,
                    'amount': amount,
                    'category': category,
                    'date': date.toIso8601String(),
                    'notes': notes,
                  };

                  if (expense == null) {
                    // TODO: Implement insertExpense in DatabaseService
                    // await _db.insertExpense(expenseData);
                  } else {
                    // TODO: Implement updateExpense in DatabaseService
                    // await _db.updateExpense(expense['id'], expenseData);
                  }
                  Navigator.pop(context);
                  _loadExpenses();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving expense: $e')),
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
        title: Text('Expense Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildExpenseSummary(),
                Expanded(
                  child: _expenses.isEmpty
                      ? Center(child: Text('No expenses recorded'))
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text(expense['description']),
                                subtitle: Text(
                                  'Category: ${expense['category']}\n'
                                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['date']))}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currencyFormat.format(expense['amount']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: ListTile(
                                            leading: Icon(Icons.edit),
                                            title: Text('Edit'),
                                          ),
                                          onTap: () => Future.delayed(
                                            Duration(seconds: 0),
                                            () => _showAddEditExpenseDialog(expense),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Colors.red),
                                            title: Text('Delete',
                                                style:
                                                    TextStyle(color: Colors.red)),
                                          ),
                                          onTap: () async {
                                            // TODO: Implement deleteExpense
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditExpenseDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  Widget _buildExpenseSummary() {
    double totalExpenses = _expenses.fold(
        0, (sum, expense) => sum + (expense['amount'] as num).toDouble());

    Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      final category = expense['category'] as String;
      final amount = (expense['amount'] as num).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Total Expenses: ${_currencyFormat.format(totalExpenses)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            ...categoryTotals.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '${entry.key}: ${_currencyFormat.format(entry.value)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
