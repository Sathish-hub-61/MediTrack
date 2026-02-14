import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/history_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../home_dashboard/widgets/side_drawer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All Time'; // 'All Time' or 'Last 30 Days'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;
    final medicineProvider =
        Provider.of<MedicineProvider>(context, listen: false);

    if (user == null) {
      return const Center(child: Text("Please login to view history"));
    }

    return Scaffold(
      drawer: const SideDrawer(), // Allow sidebar access from History too
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: "History",
              variant: CustomAppBarVariant.standard,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    icon: Icon(Icons.filter_list,
                        color: theme.colorScheme.primary),
                    dropdownColor: theme.colorScheme.surface,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                      }
                    },
                    items: <String>['All Time', 'Last 30 Days']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: medicineProvider.getHistory(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  var logs = snapshot.data!.map((json) {
                    return HistoryModel.fromMap(json);
                  }).toList();

                  // Client-side filtering for Date Range
                  if (_selectedFilter == 'Last 30 Days') {
                    final thirtyDaysAgo =
                        DateTime.now().subtract(const Duration(days: 30));
                    logs = logs
                        .where((l) => l.timestamp.isAfter(thirtyDaysAgo))
                        .toList();
                  }

                  if (logs.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildLogCard(theme, log);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            "No history logs found",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(ThemeData theme, HistoryModel log) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action).withValues(alpha: 0.1),
          child: Icon(
            _getActionIcon(log.action),
            color: _getActionColor(log.action),
            size: 20,
          ),
        ),
        title: Text(
          log.action,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          log.details,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          DateFormat('MMM d, h:mm a').format(log.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'added':
        return Colors.green;
      case 'disposed':
        return Colors.red;
      case 'edited':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'added':
        return Icons.add_circle;
      case 'disposed':
        return Icons.delete;
      case 'edited':
        return Icons.edit;
      default:
        return Icons.history;
    }
  }
}
