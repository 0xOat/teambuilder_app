import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบจัดการร้านอาหาร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ภาพรวม',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            orders.when(
              data: (orderList) => _buildDashboard(context, orderList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
            ),
            const SizedBox(height: 32),
            Text(
              'เมนูการจัดการ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'หมวดหมู่',
                    Icons.category,
                    Colors.blue,
                    () => context.go('/categories'),
                  ),
                  _buildMenuCard(
                    context,
                    'รายการอาหาร',
                    Icons.restaurant_menu,
                    Colors.green,
                    () => context.go('/foods'),
                  ),
                  _buildMenuCard(
                    context,
                    'คำสั่งซื้อ',
                    Icons.receipt_long,
                    Colors.orange,
                    () => context.go('/orders'),
                  ),
                  _buildMenuCard(
                    context,
                    'รายงาน',
                    Icons.analytics,
                    Colors.purple,
                    () => context.go('/reports'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<Order> orders) {
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    final preparingOrders = orders.where((o) => o.status == OrderStatus.preparing).length;
    final todayOrders = orders.where((o) => 
      o.orderDate.day == DateTime.now().day &&
      o.orderDate.month == DateTime.now().month &&
      o.orderDate.year == DateTime.now().year
    ).length;
    final todayRevenue = orders.where((o) => 
      o.orderDate.day == DateTime.now().day &&
      o.orderDate.month == DateTime.now().month &&
      o.orderDate.year == DateTime.now().year &&
      o.status == OrderStatus.served
    ).fold<double>(0, (sum, order) => sum + order.totalAmount);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('รอดำเนินการ', pendingOrders.toString(), Colors.red),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('กำลังเตรียม', preparingOrders.toString(), Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('คำสั่งวันนี้', todayOrders.toString(), Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('รายได้วันนี้', '${todayRevenue.toStringAsFixed(0)}฿', Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}