import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';

class AdminReportsAnalyticsTab extends StatefulWidget {
  const AdminReportsAnalyticsTab({super.key});

  @override
  State<AdminReportsAnalyticsTab> createState() => _AdminReportsAnalyticsTabState();
}

class _AdminReportsAnalyticsTabState extends State<AdminReportsAnalyticsTab> {
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
              _buildTitleRow(),
              const SizedBox(height: 16),
              _buildTimeFilters(),
              const SizedBox(height: 24),
              _buildGmvSection(),
              const SizedBox(height: 16),
              _buildMetricsRow(),
              const SizedBox(height: 16),
              _buildSuccessRateCard(),
              const SizedBox(height: 16),
              _buildCategorySalesCard(),
              const SizedBox(height: 24),
              _buildTopHubsSection(),
              const SizedBox(height: 24),
              _buildOperationalEfficiencySection(),
              const SizedBox(height: 24),
              _buildReportsExportSection(),
              const SizedBox(height: 24),
              _buildGenerateReportButton(),
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
          decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('HarvestHub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                  child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                ),
              ],
            ),
            const Text('Reports', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
        ),
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
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
        const CircleAvatar(backgroundColor: AppColors.primaryContainer, radius: 16, child: Icon(Icons.person, color: Colors.white, size: 20)),
      ],
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Platform Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              SizedBox(height: 4),
              Text('Real-time marketplace revenue, volume, and node logistics', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.show_chart, color: AppColors.onSecondaryContainer),
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Today', false),
          const SizedBox(width: 8),
          _buildFilterChip('This Week', false),
          const SizedBox(width: 8),
          _buildFilterChip('This Month (Oct 2024)', true, hasDropdown: true),
          const SizedBox(width: 8),
          _buildFilterChip('Custom', false, isIcon: true, icon: Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {bool hasDropdown = false, bool isIcon = false, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isIcon ? 12 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (isIcon && icon != null) Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          if (isIcon && icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          if (hasDropdown) const SizedBox(width: 4),
          if (hasDropdown) Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildGmvSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.payments_outlined, size: 16, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  const Text('GROSS MERCHANDISE VOL (GMV)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, size: 12, color: AppColors.onSecondaryContainer),
                    SizedBox(width: 4),
                    Text('+22%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Rs. 1,420,500', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  SizedBox(height: 4),
                  Text('vs September (Rs. 1,164,340)', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
              // Simulated sparkline graph using icon/container
              SizedBox(
                width: 100,
                height: 40,
                child: CustomPaint(
                  painter: _SparklinePainter(color: AppColors.primaryContainer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
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
                  children: const [
                    Icon(Icons.pie_chart_outline, size: 16, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text('HUB FEES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rs. 20 / completed order', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                const Text('Rs. 36,840', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
                const SizedBox(height: 4),
                const Text('1,842 total runs', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
                  children: const [
                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text('FARMER PAYOUTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Disbursed directly', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                const Text('Rs. 1,383,660', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, size: 12, color: AppColors.primaryContainer),
                    SizedBox(width: 4),
                    Text('100% cleared', style: TextStyle(fontSize: 11, color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessRateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.verified, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Fulfillment Success Rate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                Text('Orders picked within fresh shelf window', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('96.8%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
              Text('+1.4% MoM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySalesCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.pie_chart, size: 18, color: AppColors.primaryContainer),
                  SizedBox(width: 8),
                  Text('Category Sales Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                ],
              ),
              Text('Oct 1 - Oct 31', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(flex: 42, child: Container(height: 12, color: AppColors.primaryContainer)),
                Expanded(flex: 28, child: Container(height: 12, color: AppColors.secondaryContainer)),
                Expanded(flex: 18, child: Container(height: 12, color: const Color(0xFFC0DFC0))),
                Expanded(flex: 12, child: Container(height: 12, color: const Color(0xFFD6DDD6))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(color: AppColors.primaryContainer, label: 'Fresh Veggies', percentage: '42%', value: 'Rs. 596k'),
                    const SizedBox(height: 12),
                    _buildLegendItem(color: const Color(0xFFC0DFC0), label: 'Farm Dairy', percentage: '18%', value: 'Rs. 255k'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(color: AppColors.secondaryContainer, label: 'Fruits', percentage: '28%', value: 'Rs. 397k'),
                    const SizedBox(height: 12),
                    _buildLegendItem(color: const Color(0xFFD6DDD6), label: 'Honey & ...', percentage: '12%', value: 'Rs. 172k'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String percentage, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(
                children: [
                  Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(width: 4),
                  Text('($value)', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopHubsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.storefront, size: 18, color: AppColors.primaryContainer),
                SizedBox(width: 8),
                Text('Top Hubs & Producers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              ],
            ),
            Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
          ],
        ),
        const SizedBox(height: 16),
        _buildHubItem(
          rank: '#1',
          title: 'Karachi Farmers Market',
          subtitle: 'Stall 14B • Main Court',
          orders: '680 orders',
          revenue: 'Rs. 540k',
        ),
        const SizedBox(height: 12),
        _buildHubItem(
          rank: '#2',
          title: 'Clifton Green Hub',
          subtitle: 'Block 4 Pavilion',
          orders: '490 orders',
          revenue: 'Rs. 410k',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  image: const DecorationImage(image: AssetImage('assets/images/harvest_ai_assistant_bg.jpg'), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('Green Valley Farm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        SizedBox(width: 4),
                        Icon(Icons.verified, size: 14, color: AppColors.primaryContainer),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Tariq Mehmood • Malir District • 420 orders', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.star_border, size: 12, color: AppColors.onSecondaryContainer),
                    SizedBox(width: 2),
                    Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHubItem({required String rank, required String title, required String subtitle, required String orders, required String revenue}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF0F5F0), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('•', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ),
                    Text(orders, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                  ],
                ),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildOperationalEfficiencySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.speed, size: 18, color: AppColors.onSurface),
                SizedBox(width: 8),
                Text('Operational Efficiency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: const Text('OPTIMAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildEfficiencyBox('Pickup\nTurnaround', '4.2', 'm', 'Fast handover', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildEfficiencyBox('Unclaimed Rate', '1.2', '%', '<2.0% Target met', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildEfficiencyBox('Audit Speed', '4.8', 'h', 'Farmer verified', true)),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyBox(String title, String value, String unit, String subtitle, bool isSubtitleGreen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSubtitleGreen ? AppColors.primaryContainer : AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsExportSection() {
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.download, size: 18, color: AppColors.primaryContainer),
            SizedBox(width: 8),
            Text('Reports & Ledger Exports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          ],
        ),
        const SizedBox(height: 16),
        _buildExportItem('Export Tax & Revenue CSV', 'Includes hub fees and provincial tax ledger', Icons.table_chart_outlined, AppColors.secondaryContainer),
        const SizedBox(height: 12),
        _buildExportItem('Monthly Farmer Statement PDF', 'Batch disbursements, weights, and returns', Icons.description_outlined, AppColors.surfaceVariant),
      ],
    );
  }

  Widget _buildExportItem(String title, String subtitle, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.onSurface, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.file_download_outlined, color: AppColors.onSurface),
        ],
      ),
    );
  }

  Widget _buildGenerateReportButton() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          label: const Text('Generate Detailed Audit Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Automated signed reconciliation generated in 30 seconds',
          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;

  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);

    // Optional gradient fill under line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
