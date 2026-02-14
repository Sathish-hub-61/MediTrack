import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              accountName: Text(user?.displayName ?? "User"),
              accountEmail: Text(user?.email ?? user?.phoneNumber ?? "N/A"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.onPrimary,
                child: Text(
                  user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0].toUpperCase()
                      : "U",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Menu Items
            ListTile(
              leading: Icon(
                Icons.home,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to home, clearing stack to avoid duplicates
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-dashboard', (route) => false);
              },
            ),

            ListTile(
              leading: Icon(
                Icons.history,
                color: theme.colorScheme.primary,
              ),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/history-screen');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile-screen');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings-screen');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.notifications,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/notifications-screen');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.help,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/help-support-screen');
              },
            ),

            const Divider(),

            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil('/login-screen', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
