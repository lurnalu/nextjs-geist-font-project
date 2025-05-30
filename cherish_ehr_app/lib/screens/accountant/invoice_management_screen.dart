import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class InvoiceManagementScreen extends StatefulWidget {
  @override
  _InvoiceManagementScreenState createState() => _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  bool _isLoading = true;
  List<Map<String, dynamic>> _invoices = [];
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement getInvoices in DatabaseService
      // _invoices = await _db.getInvoices();
      setState(() => _invoices = []); // Temporary empty list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredInvoices {
    if (_filterStatus == 'ALL') return _invoices;
    return _invoices
        .where((invoice) => invoice['status'] == _filterStatus)
        .toList();
  }

  void _generateInvoicePDF(Map<String, dynamic> invoice) {
    // TODO: Implement PDF generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating invoice PDF...')),
    );
  }

  void _sendInvoiceEmail(Map<String, dynamic> invoice) {
    // TODO: Implement email sending
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending invoice via email...')),
    );
  }

  void _recordPayment(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invoice #${invoice['invoiceNumber']}'),
            Text('Patient: ${invoice['patientName']}'),
            Text('Amount: ${_currencyFormat.format(invoice['amount'])}'),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Payment Method'),
              items: [
                'CASH',
                'MPESA',
                'CARD',
                'BANK_TRANSFER',
                'INSURANCE'
              ].map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              )).toList(),
              onChanged: (value) {
                // Handle payment method selection
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reference Number'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement payment recording
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment recorded successfully')),
              );
            },
            child: Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Management'),
        actions: [
          DropdownButton<String>(
            value: _filterStatus,
            items: ['ALL', 'PENDING', 'PAID', 'OVERDUE', 'CANCELLED']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filterStatus = value);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInvoiceSummary(),
                Expanded(
                  child: _filteredInvoices.isEmpty
                      ? Center(child: Text('No invoices found'))
                      : ListView.builder(
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoices[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Invoice #${invoice['invoiceNumber']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Patient: ${invoice['patientName']}\n'
                                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(invoice['date']))}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currencyFormat.format(invoice['amount']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      invoice['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(invoice['status']),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Services:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ...List.generate(
                                          3, // Replace with actual services
                                          (index) => ListTile(
                                            dense: true,
                                            title: Text('Service ${index + 1}'),
                                            trailing: Text(
                                                _currencyFormat.format(100.0)),
                                          ),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                              icon: Icon(Icons.picture_as_pdf),
                                              label: Text('Generate PDF'),
                                              onPressed: () =>
                                                  _generateInvoicePDF(invoice),
                                            ),
                                            TextButton.icon(
                                              icon: Icon(Icons.email),
                                              label: Text('Send Email'),
                                              onPressed: () =>
                                                  _sendInvoiceEmail(invoice),
                                            ),
                                            if (invoice['status'] == 'PENDING')
                                              TextButton.icon(
                                                icon: Icon(Icons.payment),
                                                label: Text('Record Payment'),
                                                onPressed: () =>
                                                    _recordPayment(invoice),
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create new invoice
        },
        child: Icon(Icons.add),
        tooltip: 'Create Invoice',
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    double totalAmount = _filteredInvoices.fold(
        0, (sum, invoice) => sum + (invoice['amount'] as num).toDouble());
    int totalInvoices = _filteredInvoices.length;
    int pendingInvoices = _filteredInvoices
        .where((invoice) => invoice['status'] == 'PENDING')
        .length;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Invoice Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Amount',
                  _currencyFormat.format(totalAmount),
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Total Invoices',
                  totalInvoices.toString(),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Pending',
                  pendingInvoices.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
