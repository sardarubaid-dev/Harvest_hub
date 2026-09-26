import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';

class AdminOrderModerationTab extends StatefulWidget {
  const AdminOrderModerationTab({super.key});

  @override
  State<AdminOrderModerationTab> createState() => _AdminOrderModerationTabState();
}

class _AdminOrderModerationTabState extends State<AdminOrderModerationTab> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All 142', 'Pending 12', 'Confirmed 28', 'Ready at H...'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchAndDate(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 24),
              _buildLiveDistributionBanner(),
              const SizedBox(height: 24),
              _buildOrderCardReady(),
              const SizedBox(height: 16),
              _buildOrderCardPending(),
              const SizedBox(height: 16),
              _buildOrderCardOverdue(),
              const SizedBox(height: 16),
              _buildOrderCardCompleted(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'HarvestHub',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            const Text(
              'Orders',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          radius: 16,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchAndDate() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search order ID (#HH...),',
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 8),
              Text('Today, Oct 24', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveDistributionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.storefront, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'LIVE DISTRIBUTION\nPOINT',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(4)),
                      child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Karachi Hub Counter 14B',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.schedule, size: 14, color: AppColors.primaryContainer),
                    SizedBox(width: 4),
                    Text('18 Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(' waiting for', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const Text('customer collection today', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('Queue Pace', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text('~4 min', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardReady() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE8EFE8), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Order #HH10245', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Text('Stall 14B • 5:30 PM - 6:00 PM', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.onSecondaryContainer),
                    SizedBox(width: 4),
                    Text('Ready at Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAF3), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Customer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Ubaid Rehman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('+92 300 1234567', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Producer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Row(
                        children: const [
                          Text('Green Valley Farm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
                          SizedBox(width: 4),
                          Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryContainer),
                        ],
                      ),
                      const Text('Malir Basin (Fresh Dawn Yield)', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.onSurfaceVariant),
              SizedBox(width: 8),
              Expanded(
                child: Text('3 items (Tomatoes 1kg, Spinach 2 bunches, Pure Cow Milk 1L)', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Rs. 580', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Cash on Pickup', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
              const Text('Batch Checked 4:45 PM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildImagePlaceholder(),
              const SizedBox(width: 8),
              _buildImagePlaceholder(),
              const SizedBox(width: 8),
              _buildImagePlaceholder(),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('3/3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Text('INSPECTED', style: TextStyle(fontSize: 6, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('View Receipt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: Color(0xFFD6DDD6)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  label: const Text('Send SMS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: AppColors.surfaceVariant),
    );
  }

  Widget _buildOrderCardPending() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.onSurfaceVariant, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Order #HH1024', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Text('Slot Assigned: To...', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.error),
                    SizedBox(width: 4),
                    Text('Pending Confirmation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAF3), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Customer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Sara Khan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('+92 321 9876543', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Producer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Meadow Dairy Farm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('Awaiting Dispatch Ping', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.onSurfaceVariant),
              SizedBox(width: 8),
              Expanded(
                child: Text('2 items (Wild Mountain Honey 500g, Desi Gh...)', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Rs. 2,450', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Prepaid Online', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ),
                ],
              ),
              const Text('Elapsed: 38 mins', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Notify Farmer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    backgroundColor: AppColors.surfaceVariant.withOpacity(0.5),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync_alt, size: 18),
                  label: const Text('Reassign Stall'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    backgroundColor: AppColors.surfaceVariant.withOpacity(0.5),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardOverdue() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Order #HH10241', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Text('Overdue by 90 minutes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.error_outline, size: 12, color: AppColors.error),
                    SizedBox(width: 4),
                    Text('Pickup Overdue', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.ac_unit, size: 16, color: AppColors.error),
              SizedBox(width: 8),
              Expanded(
                child: Text('Customer missed 4:00 PM slot. Perishable crate safely moved into temperature-controlled cold locker #04.', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAF3), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Customer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Farhan Ali', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('Attempted call: Unreach...', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Producer', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Sindh Bio-Greens', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('Crate Value: Rs. 840', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Reschedule Slot'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    backgroundColor: AppColors.surfaceVariant.withOpacity(0.5),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                  label: const Text('Cancel & Restock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardCompleted() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0F5F0), shape: BoxShape.circle, border: Border.all(color: AppColors.primaryContainer)),
                child: const Icon(Icons.check, color: AppColors.primaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Order #HH10238', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Text('Collected today at 2:15 PM', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                child: const Text('Completed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAF3), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('Dr. Bilal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    SizedBox(width: 8),
                    Icon(Icons.circle, size: 4, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 8),
                    Text('Verified by OTP PIN', style: TextStyle(fontSize: 14, color: AppColors.primaryContainer)),
                  ],
                ),
                const Text('Rs. 1,200', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primaryContainer),
              SizedBox(width: 4),
              Text('View Audit Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
            ],
          ),
        ],
      ),
    );
  }
}
