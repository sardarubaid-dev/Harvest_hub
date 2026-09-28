import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market_model.dart';
import '../../models/pickup_slot_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class FarmerMarketPickupScreen extends StatefulWidget {
  const FarmerMarketPickupScreen({super.key});

  @override
  State<FarmerMarketPickupScreen> createState() =>
      _FarmerMarketPickupScreenState();
}

class _FarmerMarketPickupScreenState extends State<FarmerMarketPickupScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? _selectedMarketId;

  Future<void> _showAddSlotDialog(
    BuildContext context,
    String marketId,
    String farmerId,
  ) async {
    final dateCtrl = TextEditingController(
      text: DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
    );
    final startCtrl = TextEditingController(text: '08:00 AM');
    final endCtrl = TextEditingController(text: '12:00 PM');
    final maxCtrl = TextEditingController(text: '15');

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Pickup Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endCtrl,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Bookings Capacity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people_outline, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create Slot'),
          ),
        ],
      ),
    );

    if (created == true) {
      try {
        final newSlot = PickupSlotModel(
          id: '',
          marketId: marketId,
          farmerId: farmerId,
          date: dateCtrl.text.trim(),
          startTime: startCtrl.text.trim(),
          endTime: endCtrl.text.trim(),
          isAvailable: true,
          maxBookings: int.tryParse(maxCtrl.text.trim()) ?? 10,
          currentBookings: 0,
        );

        await _dbService.addPickupSlot(newSlot);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup slot added successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add slot: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Market & Pickup Locations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<MarketModel>>(
        stream: _dbService.streamMarkets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading market information',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final markets = snapshot.data ?? [];

          if (markets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No markets available at this time',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_selectedMarketId == null ||
              !markets.any((m) => m.id == _selectedMarketId)) {
            
            if (farmer?.marketId != null &&
                markets.any((m) => m.id == farmer!.marketId)) {
              _selectedMarketId = farmer!.marketId;
            } else {
              _selectedMarketId = markets.first.id;
            }
          }

          final currentMarket =
              markets.firstWhere((m) => m.id == _selectedMarketId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              
              const Text(
                'Select Operating Market',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: markets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final m = markets[index];
                    final isSelected = m.id == _selectedMarketId;
                    final isAssigned = m.id == farmer?.marketId;

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m.name),
                          if (isAssigned) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 14, color: Colors.white),
                          ],
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedMarketId = m.id);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            currentMarket.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: currentMarket.activeStatus
                                ? AppColors.onTertiaryContainer
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentMarket.activeStatus ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentMarket.activeStatus
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentMarket.id == farmer?.marketId) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Your Assigned Primary Market Stall',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (currentMarket.description != null &&
                        currentMarket.description!.isNotEmpty) ...[
                      Text(
                        currentMarket.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _buildMarketInfoRow(
                      Icons.location_on_outlined,
                      'Address',
                      currentMarket.address,
                    ),
                    const SizedBox(height: 10),
                    _buildMarketInfoRow(
                      Icons.access_time,
                      'Operating Hours',
                      currentMarket.operatingHours,
                    ),
                    const SizedBox(height: 10),
                    _buildMarketInfoRow(
                      Icons.map_outlined,
                      'GPS Coordinates',
                      currentMarket.gpsCoordinates,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Pickup Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddSlotDialog(
                      context,
                      currentMarket.id,
                      farmer?.id ?? '',
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Slot'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              StreamBuilder<List<PickupSlotModel>>(
                stream: _dbService.streamPickupSlots(marketId: currentMarket.id),
                builder: (context, slotSnapshot) {
                  if (slotSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }

                  final slots = slotSnapshot.data ?? [];

                  if (slots.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 44,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No pickup slots scheduled for this market',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a pickup slot so customers can book pickups at this location.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () => _showAddSlotDialog(
                              context,
                              currentMarket.id,
                              farmer?.id ?? '',
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add First Slot'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      final isFull = slot.currentBookings >= slot.maxBookings;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isFull
                                    ? AppColors.errorContainer
                                    : AppColors.onTertiaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 20,
                                color: isFull ? AppColors.error : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.date,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${slot.startTime} - ${slot.endTime}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${slot.currentBookings} / ${slot.maxBookings} bookings',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isFull
                                          ? AppColors.error
                                          : AppColors.outline,
                                      fontWeight: isFull
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isFull
                                    ? AppColors.errorContainer
                                    : AppColors.onTertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isFull ? 'FULL' : 'AVAILABLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isFull ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarketInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
