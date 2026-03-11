import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/medicine_provider.dart';
import '../../../widgets/custom_bottom_bar.dart';
import 'home_dashboard_initial_page.dart';
import '../history_screen/history_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../ai_assistant_screen/ai_assistant_screen.dart';

import 'widgets/side_drawer.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  HomeDashboardState createState() => HomeDashboardState();
}

class HomeDashboardState extends State<HomeDashboard> {
  int currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboardInitialPage(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('HomeDashboard: initState called');
  }

  @override
  Widget build(BuildContext context) {
    // Watch expiring count for badge
    final expiringCount = Provider.of<MedicineProvider>(context).expiringCount;
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const SideDrawer(),
      endDrawer: const AIAssistantScreen(),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed('/add-medicine-screen');
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              label: const Text('Add Medicine'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        homeBadgeCount: expiringCount,
      ),
    );
  }
}
