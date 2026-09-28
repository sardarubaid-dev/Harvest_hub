import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/order_model.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:intl/intl.dart';
import 'admin_order_details_screen.dart';

class AdminOrderModerationTab extends StatefulWidget {
  const AdminOrderModerationTab({super.key});

  @override
  State<AdminOrderModerationTab> createState() => _AdminOrderModerationTabState();
}

class _AdminOrderModerationTabState extends State<AdminOrderModerationTab> {
  int _selectedFilterIndex = 0;
  final _dbService = DatabaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  // Metrics state
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _readyOrders = 0;
  int _completedOrders = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialOrders();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchMoreOrders();
    }
  }

  Future<void> _fetchInitialOrders() async {
    setState(() => _isLoading = true);
    
    // In a real app we'd aggregate these on backend. We'll simulate fetching all just for counts if needed, 
    // but here we just paginate the view. For simplicity we'll assume the top filters just filter what's loaded.
    // Or we fetch first 20.
    final result = await _dbService.getPaginatedOrders(limit: 20);
    
    // Simulate counts for UI demo since firebase doesn't have easy aggregate without cost
    // Normally this would be a separate aggregation query
    
    if (mounted) {
      setState(() {
        _orders = result['orders'] as List<OrderModel>;
        _lastDoc = result['lastDoc'] as DocumentSnapshot?;
        _hasMore = _orders.length == 20;
        
        // Calculate rough local metrics based on first batch or overall estimation
        _updateLocalMetrics();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreOrders() async {
    setState(() => _isLoadingMore = true);
    final result = await _dbService.getPaginatedOrders(limit: 20, startAfter: _lastDoc);
    final newOrders = result['orders'] as List<OrderModel>;
    
    if (mounted) {
      setState(() {
        _orders.addAll(newOrders);
        _lastDoc = result['lastDoc'] as DocumentSnapshot?;
        _hasMore = newOrders.length == 20;
        _isLoadingMore = false;
        _updateLocalMetrics();
      });
    }
  }
  
  void _updateLocalMetrics() {
    _totalOrders = _orders.length;
    _pendingOrders = _orders.where((o) => o.status == 'pending').length;
    _readyOrders = _orders.where((o) => o.status == 'ready').length;
    _completedOrders = _orders.where((o) => o.status == 'completed').length;
  }

  List<String> get _filters {
    return ['All $_totalOrders', 'Pending $_pendingOrders', 'Ready at Hub $_readyOrders', 'Completed $_completedOrders'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchInitialOrders,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
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
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _buildSliverOrderList(),
                    if (_isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    ),
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
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
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
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            } else {
              setState(() {
                _selectedDate = null;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  _selectedDate != null 
                      ? DateFormat('MMM d').format(_selectedDate!) 
                      : 'All Time', 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    child: const Icon(Icons.close, size: 14),
                  ),
                ],
              ],
            ),
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
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.primaryContainer),
                    const SizedBox(width: 4),
                    Text('$_pendingOrders Orders', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const Text(' waiting for', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
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

  Widget _buildSliverOrderList() {
    List<OrderModel> filteredOrders = _orders;
    
    // Status Filter
    if (_selectedFilterIndex == 1) {
      filteredOrders = filteredOrders.where((o) => o.status == 'pending').toList();
    } else if (_selectedFilterIndex == 2) {
      filteredOrders = filteredOrders.where((o) => o.status == 'ready').toList();
    } else if (_selectedFilterIndex == 3) {
      filteredOrders = filteredOrders.where((o) => o.status == 'completed').toList();
    }

    // Date Filter
    if (_selectedDate != null) {
      filteredOrders = filteredOrders.where((o) {
        return o.createdAt.year == _selectedDate!.year &&
               o.createdAt.month == _selectedDate!.month &&
               o.createdAt.day == _selectedDate!.day;
      }).toList();
    }

    // Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredOrders = filteredOrders.where((o) => o.id.toLowerCase().contains(q) || o.customerId.toLowerCase().contains(q)).toList();
    }

    if (filteredOrders.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              _orders.isEmpty ? 'No orders placed yet.' : 'No orders match your filters.', 
              style: const TextStyle(color: AppColors.onSurfaceVariant)
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderCard(filteredOrders[index]),
            );
          },
          childCount: filteredOrders.length,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    if (order.status == 'ready') {
      statusColor = AppColors.onSecondaryContainer;
      statusBgColor = AppColors.secondaryContainer;
      statusText = 'Ready at Hub';
      statusIcon = Icons.circle;
    } else if (order.status == 'pending') {
      statusColor = AppColors.onSurfaceVariant;
      statusBgColor = AppColors.surfaceVariant;
      statusText = 'Pending';
      statusIcon = Icons.schedule;
    } else if (order.status == 'completed') {
      statusColor = AppColors.primaryContainer;
      statusBgColor = const Color(0xFFE8EFE8);
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppColors.error;
      statusBgColor = AppColors.errorContainer;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel;
    }

    final dateStr = DateFormat('MMM d, h:mm a').format(order.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminOrderDetailsScreen(orderId: order.id)),
        );
      },
      child: Container(
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
                    children: [
                      Text('Order #${order.id.substring(0, min(8, order.id.length)).toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 10, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text('Rs. ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Items', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text('${order.items.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
