import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../home_dashboard/widgets/side_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System Default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildFaqItem(
              context,
              'How do I add a medicine?',
              'Go to the Home Dashboard and tap the "+" button. Scan the barcode or enter details manually.',
            ),
            _buildFaqItem(
              context,
              'How does the alert system work?',
              'You can set an alert threshold in your Profile. We will notify you via SMS or App Notification before your medicine expires.',
            ),
            SizedBox(height: 4.h),
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@meditrack.com'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(answer),
        ],
      ),
    );
  }
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: const Column(
          children: [
            Text(
              'Your privacy is our priority. We only store necessary data to provide you with medicine alerts.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Add more privacy policy text here
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No new notifications')),
    );
  }
}
