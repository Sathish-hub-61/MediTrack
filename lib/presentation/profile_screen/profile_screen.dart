import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../home_dashboard/widgets/side_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State for Toggles
  bool _smsAlerts = true;
  bool _voiceCallAlerts = false;
  bool _appNotifications = true;

  // State for Slider
  double _expiryAlertDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userModel = UserModel(
      id: user?.uid ?? 'guest',
      phone: user?.phoneNumber ?? 'N/A',
      name: user?.displayName ?? 'User',
      email: user?.email ?? '',
    );

    return Scaffold(
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: "Profile",
              variant: CustomAppBarVariant.standard,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Profile Header
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        userModel.name.isNotEmpty
                            ? userModel.name[0].toUpperCase()
                            : 'U',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      userModel.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userModel.email.isNotEmpty
                          ? userModel.email
                          : userModel.phone,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Profile Options
                    OutlinedButton(
                      onPressed: () => _showEditProfileDialog(
                          context, userModel, authProvider),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                      child: const Text("Edit Profile"),
                    ),

                    SizedBox(height: 4.h),

                    // Notification Preferences
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Notification Preferences",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(context, "SMS Alerts", _smsAlerts,
                              (val) {
                            setState(() => _smsAlerts = val);
                          }),
                          const Divider(height: 1),
                          _buildSwitchTile(
                              context, "Voice Call Alerts", _voiceCallAlerts,
                              (val) {
                            setState(() => _voiceCallAlerts = val);
                          }),
                          const Divider(height: 1),
                          _buildSwitchTile(
                              context, "App Notifications", _appNotifications,
                              (val) {
                            setState(() => _appNotifications = val);
                          }),
                          const Divider(height: 1),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 1.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Alert before expiry",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      "${_expiryAlertDays.toInt()} days",
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _expiryAlertDays,
                                  min: 1,
                                  max: 60,
                                  divisions: 59,
                                  label: "${_expiryAlertDays.toInt()} days",
                                  onChanged: (val) {
                                    setState(() {
                                      _expiryAlertDays = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _buildProfileOption(
                      context,
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/privacy-security-screen');
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pushNamed(context, '/help-support-screen');
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamedAndRemoveUntil(
                              '/login-screen',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer,
                          foregroundColor: theme.colorScheme.onErrorContainer,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
      BuildContext context, UserModel user, AuthProvider auth) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await auth.updateUserProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Handle error
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
      visualDensity: VisualDensity.compact,
    );
  }
}
