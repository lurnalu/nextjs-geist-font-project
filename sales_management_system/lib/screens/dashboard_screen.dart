import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final theme = Theme.of(context);

    List<Widget> _buildQuickActions(UserRole role) {
      final actions = <Widget>[];

      switch (role) {
        case UserRole.admin:
          actions.addAll([
            _QuickActionCard(
              icon: Icons.people,
              title: 'Users',
              onTap: () {
                // Navigate to user management
              },
            ),
            _QuickActionCard(
              icon: Icons.inventory,
              title: 'Products',
              onTap: () {
                // Navigate to product management
              },
            ),
            _QuickActionCard(
              icon: Icons.bar_chart,
              title: 'Reports',
              onTap: () {
                // Navigate to reports
              },
            ),
            _QuickActionCard(
              icon: Icons.backup,
              title: 'Backup',
              onTap: () {
                // Handle backup
              },
            ),
          ]);
          break;

        case UserRole.cashier:
          actions.addAll([
            _QuickActionCard(
              icon: Icons.shopping_cart,
              title: 'New Sale',
              onTap: () {
                // Navigate to new sale
              },
            ),
            _QuickActionCard(
              icon: Icons.person_add,
              title: 'Add Customer',
              onTap: () {
                // Navigate to add customer
              },
            ),
            _QuickActionCard(
              icon: Icons.receipt_long,
              title: 'Recent Sales',
              onTap: () {
                // Navigate to recent sales
              },
            ),
          ]);
          break;

        case UserRole.manager:
          actions.addAll([
            _QuickActionCard(
              icon: Icons.analytics,
              title: 'Analytics',
              onTap: () {
                // Navigate to analytics
              },
            ),
            _QuickActionCard(
              icon: Icons.inventory_2,
              title: 'Stock',
              onTap: () {
                // Navigate to stock management
              },
            ),
            _QuickActionCard(
              icon: Icons.summarize,
              title: 'Summary',
              onTap: () {
                // Navigate to summary
              },
            ),
          ]);
          break;
      }

      return actions;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeService.toggleTheme,
          ),
        ],
      ),
      drawer: _DashboardDrawer(
        currentUser: authService.currentUser!,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${authService.currentUser?.fullName ?? authService.currentUser?.username}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${authService.currentUser?.role.toString().split('.').last ?? ''}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _buildQuickActions(authService.currentUser!.role),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  final User currentUser;

  const _DashboardDrawer({
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.fullName ?? ''),
            accountEmail: Text(currentUser.username),
            currentAccountPicture: CircleAvatar(
              child: Text(
                (currentUser.fullName?[0] ?? currentUser.username[0]).toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          if (currentUser.role == UserRole.admin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                // Navigate to user management
                Navigator.pop(context);
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            onTap: () {
              // Navigate to products
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Customers'),
            onTap: () {
              // Navigate to customers
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Sales'),
            onTap: () {
              // Navigate to sales
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              // Navigate to reports
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
