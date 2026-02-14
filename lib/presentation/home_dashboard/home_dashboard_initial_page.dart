import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_app_bar.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/filter_chip_widget.dart';
import 'widgets/medicine_card_widget.dart';
import '../expired_medicine_alert_modal/expired_medicine_alert_modal.dart';

import '../../../providers/medicine_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/medicine_model.dart';

class HomeDashboardInitialPage extends StatefulWidget {
  const HomeDashboardInitialPage({super.key});

  @override
  State<HomeDashboardInitialPage> createState() =>
      _HomeDashboardInitialPageState();
}

class _HomeDashboardInitialPageState extends State<HomeDashboardInitialPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _alertShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medicineProvider = Provider.of<MedicineProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      medicineProvider.loadMedicines(authProvider.user!.uid);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _showExpiredAlert() {
    if (_alertShown) return;
    _alertShown = true;

    final medicineProvider = Provider.of<MedicineProvider>(
      context,
      listen: false,
    );
    final expiredMedicine = medicineProvider.medicines
        .where((m) => m.status == MedicineStatus.expired)
        .firstOrNull;

    if (expiredMedicine != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            ExpiredMedicineAlertModal(medicine: expiredMedicine),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<MedicineProvider, MedicineProvider>(
      selector: (context, provider) => provider,
      shouldRebuild: (prev, next) =>
          prev.medicines != next.medicines ||
          prev.isLoading != next.isLoading ||
          prev.expiredCount != next.expiredCount,
      builder: (context, medicineProvider, child) {
        // Trigger alert if needed
        if (medicineProvider.expiredCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showExpiredAlert();
          });
        }

        // Filter logic moved inside builder to only run when provider data changes
        List<MedicineModel> filteredList = medicineProvider.medicines;

        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          filteredList = filteredList.where((medicine) {
            return medicine.medicineName.toLowerCase().contains(searchLower) ||
                medicine.batchNumber.toLowerCase().contains(searchLower);
          }).toList();
        }

        if (_selectedFilter != 'All') {
          filteredList = filteredList.where((medicine) {
            if (_selectedFilter == 'Expiring Soon') {
              return medicine.status == MedicineStatus.warning;
            } else if (_selectedFilter == 'Expired') {
              return medicine.status == MedicineStatus.expired;
            }
            return true;
          }).toList();
        }

        return Column(
          children: [
            CustomAppBar(
              title: 'MediTrack',
              variant: CustomAppBarVariant.standard,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              ),
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications-screen');
                      },
                      tooltip: 'Notifications',
                    ),
                    if (medicineProvider.expiredCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            medicineProvider.expiredCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 2.w),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Healthy Living',
                                  style: theme.textTheme.displaySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            // Search Bar
                            Container(
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow
                                        .withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) => setState(() {}),
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Search medicines...',
                                  hintStyle:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.5.h,
                                  ),
                                  isDense: false,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            // Filter Chips Header
                            Text(
                              'Quick Filters',
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 1.5.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChipWidget(
                                    label: 'All',
                                    isSelected: _selectedFilter == 'All',
                                    onTap: () =>
                                        setState(() => _selectedFilter = 'All'),
                                  ),
                                  SizedBox(width: 2.w),
                                  FilterChipWidget(
                                    label: 'Expiring Soon',
                                    count: medicineProvider.expiringCount,
                                    color: const Color(0xFFF57C00),
                                    isSelected:
                                        _selectedFilter == 'Expiring Soon',
                                    onTap: () => setState(
                                      () => _selectedFilter = 'Expiring Soon',
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  FilterChipWidget(
                                    label: 'Expired',
                                    count: medicineProvider.expiredCount,
                                    color: const Color(0xFFD32F2F),
                                    isSelected: _selectedFilter == 'Expired',
                                    onTap: () => setState(
                                        () => _selectedFilter = 'Expired'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    medicineProvider.isLoading
                        ? const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : filteredList.isEmpty
                            ? SliverFillRemaining(
                                child: EmptyStateWidget(
                                  searchQuery: _searchController.text,
                                ),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final medicine = filteredList[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 2.h),
                                      child: MedicineCardWidget(
                                        medicine: medicine,
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pushNamed(
                                            '/medicine-detail-screen',
                                            arguments: medicine,
                                          );
                                        },
                                        onSetReminder: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Reminder set for ${medicine.medicineName}',
                                              ),
                                            ),
                                          );
                                        },
                                        onMarkDisposed: () {
                                          Provider.of<MedicineProvider>(
                                            context,
                                            listen: false,
                                          ).disposeMedicine(
                                            medicine.id,
                                            medicine.userId,
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${medicine.medicineName} marked as disposed',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }, childCount: filteredList.length),
                                ),
                              ),
                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
