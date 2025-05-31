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
    final user = authService.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeService.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _DashboardDrawer(currentUser: user),
      body: _DashboardBody(user: user),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final User user;

  const _DashboardBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        radius: 24,
                        child: Text(
                          (user.fullName?[0] ?? user.username[0]).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user.fullName ?? user.username}',
                              style: theme.textTheme.headlineSmall,
                            ),
                            Text(
                              'Role: ${user.role.toString().split('.').last}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Section
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: _buildQuickActions(context, user.role),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickActions(BuildContext context, UserRole role) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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

  const _DashboardDrawer({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.fullName ?? ''),
            accountEmail: Text(currentUser.username),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (currentUser.fullName?[0] ?? currentUser.username[0]).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
                      Navigator.pop(context);
                      // Navigate to user management
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Products'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to products
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Customers'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to customers
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Sales'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to sales
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to reports
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: 'Logout',
              onPressed: () async {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              type: ButtonType.outline,
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }
}
