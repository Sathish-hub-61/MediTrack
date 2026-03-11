import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home_dashboard/widgets/side_drawer.dart';
import '../../../providers/theme_provider.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SETTINGS SCREEN — with Dark Theme Toggle
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          // Theme Section
          _SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
          SizedBox(height: 1.h),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Dark Theme',
                subtitle:
                    themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                trailing: Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeTrackColor: theme.colorScheme.primary,
                ),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF26A69A),
                title: 'Language',
                subtitle: 'English',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // About Section
          _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
          SizedBox(height: 1.h),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF00897B),
                title: 'Version',
                subtitle: '1.0.0',
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF8D6E63),
                title: 'Licenses',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'MediTrack',
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  HELP & SUPPORT SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'satishak2005@gmail.com';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // ─── Hero Card ───
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 48),
                  SizedBox(height: 1.5.h),
                  Text(
                    'How can we help?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Find answers or reach out to our team',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // ─── FAQ Section ───
            _SectionHeader(
                title: 'Frequently Asked Questions',
                icon: Icons.quiz_outlined),
            SizedBox(height: 1.5.h),

            _FaqTile(
              question: 'How do I add a medicine?',
              answer:
                  'Tap the "+" button on the Home Dashboard. You can scan the barcode or manually enter medicine details like name, batch number, expiry date, and more.',
              icon: Icons.add_circle_outline_rounded,
            ),
            _FaqTile(
              question: 'How does the expiry alert work?',
              answer:
                  'MediTrack monitors your medicines and sends automatic notifications before they expire. You can configure the alert threshold (e.g., 30, 60, or 90 days) in your Profile settings.',
              icon: Icons.notifications_active_outlined,
            ),
            _FaqTile(
              question: 'Can my pharmacist add medicines for me?',
              answer:
                  'Yes! Your pharmacist can add medicines through the Pharmacy Portal using your registered phone number. The medicines will automatically sync to your MediTrack app.',
              icon: Icons.local_pharmacy_outlined,
            ),
            _FaqTile(
              question: 'Is my data secure?',
              answer:
                  'Absolutely. All data is encrypted and stored securely on Firebase Cloud. Only you can access your medicine data through your authenticated account.',
              icon: Icons.shield_outlined,
            ),
            _FaqTile(
              question: 'How do I use the AI Assistant?',
              answer:
                  'Tap the robot icon (🤖) on the dashboard to open the MediTrack Assistant. It can answer questions about your medicines, dosages, and general health tips. Note: It cannot diagnose symptoms.',
              icon: Icons.smart_toy_outlined,
            ),

            SizedBox(height: 3.h),

            // ─── Contact Section ───
            _SectionHeader(
                title: 'Contact Us', icon: Icons.contact_support_outlined),
            SizedBox(height: 1.5.h),

            _ContactCard(
              icon: Icons.email_rounded,
              iconColor: const Color(0xFFE53935),
              title: 'Email Support',
              subtitle: _supportEmail,
              onTap: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: _supportEmail,
                  queryParameters: {
                    'subject': 'MediTrack Support Request',
                  },
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            SizedBox(height: 1.5.h),
            _ContactCard(
              icon: Icons.phone_rounded,
              iconColor: const Color(0xFF43A047),
              title: 'Phone Support',
              subtitle: '+91 90193 05882',
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: '+919019305882');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            SizedBox(height: 1.5.h),
            _ContactCard(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Support Hours',
              subtitle: 'Mon–Sat, 9:00 AM – 6:00 PM IST',
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PRIVACY & SECURITY SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // ─── Hero Badge ───
            Center(
              child: Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: theme.colorScheme.primary,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Center(
              child: Text(
                'Your Privacy Matters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Text(
                  'MediTrack is designed with privacy at its core. We follow industry-standard practices to keep your data safe.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // ─── Data Collection ───
            _PolicySection(
              icon: Icons.data_usage_rounded,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Data We Collect',
              items: const [
                'Name, email, and phone number for account creation',
                'Medicine details (name, batch, expiry) you enter',
                'Usage analytics to improve app performance',
              ],
            ),

            SizedBox(height: 2.5.h),

            // ─── Data Storage ───
            _PolicySection(
              icon: Icons.cloud_done_rounded,
              iconColor: const Color(0xFF00897B),
              title: 'How We Store Data',
              items: const [
                'All data is stored on Google Firebase Cloud with encryption',
                'Local cache uses Hive encrypted storage on your device',
                'API keys are securely managed and never exposed',
              ],
            ),

            SizedBox(height: 2.5.h),

            // ─── Data Sharing ───
            _PolicySection(
              icon: Icons.share_rounded,
              iconColor: const Color(0xFFE53935),
              title: 'Data Sharing',
              items: const [
                'We never sell your personal data to third parties',
                'Medicine data is shared only with your authorized pharmacy',
                'AI Assistant queries are processed via secure API endpoints',
              ],
            ),

            SizedBox(height: 2.5.h),

            // ─── Your Rights ───
            _PolicySection(
              icon: Icons.gavel_rounded,
              iconColor: const Color(0xFF8D6E63),
              title: 'Your Rights',
              items: const [
                'You can delete your account and all data at any time',
                'You can export your medicine data as a report',
                'You can opt out of notifications anytime in Settings',
              ],
            ),

            SizedBox(height: 2.5.h),

            // ─── Security Measures ───
            _PolicySection(
              icon: Icons.verified_user_rounded,
              iconColor: const Color(0xFF43A047),
              title: 'Security Measures',
              items: const [
                'Firebase Authentication with OTP verification',
                'HTTPS/TLS encryption for all data in transit',
                'Firestore security rules restrict access to authenticated users',
                'Bcrypt password hashing for pharmacy portal accounts',
              ],
            ),

            SizedBox(height: 3.h),

            // ─── Last updated ───
            Center(
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Last updated: March 2026',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NOTIFICATIONS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(height: 2.h),
            Text(
              'No new notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'You\'re all caught up!',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SHARED COMPONENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: 2.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.3.h),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final IconData icon;
  const _FaqTile(
      {required this.question, required this.answer, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(
            question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding:
              EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
          children: [
            Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: 0.3.h),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _PolicySection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0.7.h),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
