import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const BillingScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      final bills = await _db.getBillingRecords(widget.patientId);
      setState(() => _bills = bills);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditBillDialog([Map<String, dynamic>? bill]) async {
    final _formKey = GlobalKey<FormState>();
    double amount = bill?['amount']?.toDouble() ?? 0.0;
    String status = bill?['status'] ?? 'PENDING';
    String? paymentMethod = bill?['paymentMethod'];
    String? notes = bill?['notes'];
    DateTime? paymentDate;
    
    // Safely parse payment date
    if (bill?['paymentDate'] != null) {
      try {
        paymentDate = DateTime.parse(bill!['paymentDate']);
      } catch (e) {
        print('Error parsing payment date: $e');
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bill == null ? 'Add Bill' : 'Edit Bill'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: ['PENDING', 'PAID', 'CANCELLED']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => status = value ?? 'PENDING'),
                ),
                if (status == 'PAID') ...[
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: InputDecoration(labelText: 'Payment Method'),
                    items: ['CASH', 'MPESA', 'CARD', 'INSURANCE']
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    validator: (value) =>
                        status == 'PAID' && (value?.isEmpty ?? true)
                            ? 'Required for paid bills'
                            : null,
                    onChanged: (value) => setState(() => paymentMethod = value),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: paymentDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => paymentDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Payment Date',
                        errorText: status == 'PAID' && paymentDate == null
                            ? 'Required for paid bills'
                            : null,
                      ),
                      child: Text(
                        paymentDate != null
                            ? DateFormat('yyyy-MM-dd').format(paymentDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
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
                  final billData = {
                    'patientId': widget.patientId,
                    'amount': amount,
                    'status': status,
                    if (status == 'PAID') ...<String, dynamic>{
                      'paymentMethod': paymentMethod,
                      'paymentDate': paymentDate?.toIso8601String(),
                    },
                    'notes': notes,
                  };

                  if (bill == null) {
                    await _db.insertBillingRecord(billData);
                  } else {
                    await _db.updateBillingRecord(bill['id'], billData);
                  }
                  Navigator.pop(context);
                  _loadBills();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving bill: $e')),
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
        title: Text('Billing - ${widget.patientName}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(),
                Expanded(
                  child: _bills.isEmpty
                      ? Center(child: Text('No billing records found'))
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _bills.length,
                          itemBuilder: (context, index) {
                            final bill = _bills[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  _currencyFormat.format(bill['amount']),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status: ${bill['status']}'),
                                    if (bill['paymentDate'] != null)
                                      Text(
                                          'Paid on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(bill['paymentDate']))}'),
                                    if (bill['paymentMethod'] != null)
                                      Text('Method: ${bill['paymentMethod']}'),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                      ),
                                      onTap: () => Future.delayed(
                                        Duration(seconds: 0),
                                        () => _showAddEditBillDialog(bill),
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
                                        final confirm =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Confirm Delete'),
                                            content: Text(
                                                'Are you sure you want to delete this bill?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
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
                                            await _db.deleteBillingRecord(
                                                bill['id']);
                                            _loadBills();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting bill: $e')),
                                            );
                                          }
                                        }
                                      },
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
        onPressed: () => _showAddEditBillDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Bill',
      ),
    );
  }

  Widget _buildSummaryCard() {
    double totalBilled = 0;
    double totalPaid = 0;
    double totalPending = 0;

    for (final bill in _bills) {
      final amount = (bill['amount'] as num).toDouble();
      totalBilled += amount;
      if (bill['status'] == 'PAID') {
        totalPaid += amount;
      } else if (bill['status'] == 'PENDING') {
        totalPending += amount;
      }
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Billing Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Billed', totalBilled, Colors.blue),
                _buildSummaryItem('Total Paid', totalPaid, Colors.green),
                _buildSummaryItem('Pending', totalPending, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
