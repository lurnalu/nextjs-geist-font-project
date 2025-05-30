import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class FinancialReportsScreen extends StatefulWidget {
  @override
  _FinancialReportsScreenState createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  bool _isLoading = true;
  Map<String, dynamic> _financialData = {};
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _db.getClinicStats(_startDate, _endDate);
      setState(() => _financialData = stats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading financial data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadFinancialData();
    }
  }

  void _exportReport() {
    // TODO: Implement report export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting report...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Financial Reports'),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: _selectDateRange,
              tooltip: 'Select Date Range',
            ),
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: _exportReport,
              tooltip: 'Export Report',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Revenue'),
              Tab(text: 'Expenses'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildRevenueTab(),
                  _buildExpensesTab(),
                  _buildSummaryTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeCard(),
          SizedBox(height: 16),
          _buildRevenueStats(),
          SizedBox(height: 16),
          _buildRevenueByService(),
          SizedBox(height: 16),
          _buildPaymentMethods(),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeCard(),
          SizedBox(height: 16),
          _buildExpenseStats(),
          SizedBox(height: 16),
          _buildExpenseCategories(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final totalRevenue = _financialData['totalRevenue'] ?? 0.0;
    final totalExpenses = _financialData['totalExpenses'] ?? 0.0;
    final netIncome = totalRevenue - totalExpenses;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeCard(),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  _buildSummaryItem(
                    'Total Revenue',
                    totalRevenue,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Total Expenses',
                    totalExpenses,
                    Colors.red,
                  ),
                  Divider(),
                  _buildSummaryItem(
                    'Net Income',
                    netIncome,
                    netIncome >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildProfitabilityMetrics(),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.date_range),
        title: Text('Report Period'),
        subtitle: Text(
          '${DateFormat('MMM d, y').format(_startDate)} - '
          '${DateFormat('MMM d, y').format(_endDate)}',
        ),
        trailing: TextButton(
          onPressed: _selectDateRange,
          child: Text('Change'),
        ),
      ),
    );
  }

  Widget _buildRevenueStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildStatRow(
              'Total Revenue',
              _financialData['totalRevenue'] ?? 0,
            ),
            _buildStatRow(
              'Average Daily Revenue',
              _financialData['averageDailyRevenue'] ?? 0,
            ),
            _buildStatRow(
              'Highest Daily Revenue',
              _financialData['highestDailyRevenue'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildStatRow(
              'Total Expenses',
              _financialData['totalExpenses'] ?? 0,
            ),
            _buildStatRow(
              'Average Daily Expenses',
              _financialData['averageDailyExpenses'] ?? 0,
            ),
            _buildStatRow(
              'Highest Daily Expenses',
              _financialData['highestDailyExpenses'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _currencyFormat.format(value),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            _currencyFormat.format(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByService() {
    // TODO: Implement revenue by service breakdown
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue by Service',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Service breakdown chart will be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    // TODO: Implement payment methods breakdown
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Payment methods chart will be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategories() {
    // TODO: Implement expense categories breakdown
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Expense categories chart will be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitabilityMetrics() {
    // TODO: Implement profitability metrics
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profitability Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Profitability metrics will be displayed here'),
          ],
        ),
      ),
    );
  }
}
