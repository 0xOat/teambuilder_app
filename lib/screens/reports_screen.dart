import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../models/order.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Default to last 7 days
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานและสถิติ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ภาพรวม'),
            Tab(text: 'ยอดขาย'),
            Tab(text: 'เมนูยอดนิยม'),
            Tab(text: 'รายละเอียด'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildPopularMenuTab(),
          _buildDetailTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final analytics = ref.watch(analyticsProvider(_selectedDateRange!));
    
    return analytics.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeDisplay(),
            const SizedBox(height: 20),
            _buildOverviewCards(data),
            const SizedBox(height: 20),
            Text(
              'สถิติรายวัน',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildDailyChart(data.dailyStats)),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
    );
  }

  Widget _buildSalesTab() {
    final analytics = ref.watch(analyticsProvider(_selectedDateRange!));
    
    return analytics.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeDisplay(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSalesCard('ยอดขายรวม', '${data.totalRevenue.toStringAsFixed(0)}฿', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSalesCard('ค่าเฉลี่ยต่อบิล', '${data.averageOrderValue.toStringAsFixed(0)}฿', Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'ยอดขายรายวัน',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildDailyRevenueChart(data.dailyStats)),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
    );
  }

  Widget _buildPopularMenuTab() {
    final analytics = ref.watch(analyticsProvider(_selectedDateRange!));
    
    return analytics.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeDisplay(),
            const SizedBox(height: 20),
            Text(
              'เมนูขายดี',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: data.popularItems.length,
                itemBuilder: (context, index) {
                  final item = data.popularItems[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item.name),
                      subtitle: Text('ขายได้ ${item.quantity} จาน'),
                      trailing: Text(
                        '${item.revenue.toStringAsFixed(0)}฿',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
    );
  }

  Widget _buildDetailTab() {
    final analytics = ref.watch(analyticsProvider(_selectedDateRange!));
    
    return analytics.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeDisplay(),
            const SizedBox(height: 20),
            Text(
              'รายละเอียดทั้งหมด',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailCard('สถิติรวม', [
                      'คำสั่งซื้อทั้งหมด: ${data.totalOrders}',
                      'ยอดขายรวม: ${data.totalRevenue.toStringAsFixed(0)}฿',
                      'ค่าเฉลี่ยต่อบิล: ${data.averageOrderValue.toStringAsFixed(0)}฿',
                      'เมนูที่ขายมากที่สุด: ${data.popularItems.isNotEmpty ? data.popularItems.first.name : '-'}',
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('สถิติตามประเภท', [
                      'ทานในร้าน: ${data.ordersByType[OrderType.dineIn] ?? 0} ออเดอร์',
                      'ห่อกลับ: ${data.ordersByType[OrderType.takeaway] ?? 0} ออเดอร์',
                      'เดลิเวอรี่: ${data.ordersByType[OrderType.delivery] ?? 0} ออเดอร์',
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('สถิติตามสถานะ', [
                      'เสิร์ฟแล้ว: ${data.ordersByStatus[OrderStatus.served] ?? 0}',
                      'ยกเลิก: ${data.ordersByStatus[OrderStatus.cancelled] ?? 0}',
                      'อื่นๆ: ${data.totalOrders - (data.ordersByStatus[OrderStatus.served] ?? 0) - (data.ordersByStatus[OrderStatus.cancelled] ?? 0)}',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
    );
  }

  Widget _buildDateRangeDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            'ช่วงเวลา: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsData data) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('คำสั่งซื้อ', '${data.totalOrders}', Colors.blue, Icons.receipt_long)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('ยอดขาย', '${data.totalRevenue.toStringAsFixed(0)}฿', Colors.green, Icons.monetization_on)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('ค่าเฉลี่ย', '${data.averageOrderValue.toStringAsFixed(0)}฿', Colors.orange, Icons.trending_up)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('เมนูยอดนิยม', '${data.popularItems.length}', Colors.purple, Icons.star)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(List<DailyStats> dailyStats) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('จำนวนคำสั่งซื้อรายวัน', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyStats.length,
              itemBuilder: (context, index) {
                final stat = dailyStats[index];
                final maxOrders = dailyStats.map((s) => s.orders).reduce((a, b) => a > b ? a : b);
                final height = maxOrders > 0 ? (stat.orders / maxOrders * 120) : 0.0;
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${stat.orders}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM').format(stat.date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueChart(List<DailyStats> dailyStats) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ยอดขายรายวัน', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyStats.length,
              itemBuilder: (context, index) {
                final stat = dailyStats[index];
                final maxRevenue = dailyStats.map((s) => s.revenue).reduce((a, b) => a > b ? a : b);
                final height = maxRevenue > 0 ? (stat.revenue / maxRevenue * 120) : 0.0;
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${stat.revenue.toInt()}', style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM').format(stat.date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}