import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('จัดการคำสั่งซื้อ'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'รอดำเนินการ'),
            Tab(text: 'กำลังเตรียม'),
            Tab(text: 'พร้อมเสิร์ฟ'),
            Tab(text: 'เสิร์ฟแล้ว'),
            Tab(text: 'ยกเลิก'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddOrderDialog(context, ref),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderStatus.pending),
          _buildOrderList(OrderStatus.preparing),
          _buildOrderList(OrderStatus.ready),
          _buildOrderList(OrderStatus.served),
          _buildOrderList(OrderStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrderStatus status) {
    return Consumer(
      builder: (context, ref, child) {
        final orders = ref.watch(ordersByStatusProvider(status));
        
        return orders.when(
          data: (orderList) {
            if (orderList.isEmpty) {
              return Center(
                child: Text('ไม่มีคำสั่งซื้อใน${_getStatusText(status)}'),
              );
            }

            return ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('ลูกค้า: ${order.customerName}'),
                            ],
                          ),
                        ),
                        Text(
                          '${order.totalAmount.toStringAsFixed(0)}฿',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ประเภท: ${_getOrderTypeText(order.orderType)}'),
                        if (order.tableNumber != null)
                          Text('โต๊ะ: ${order.tableNumber}'),
                        Text('วันที่: ${DateFormat('dd/MM/yyyy HH:mm').format(order.created)}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.customerPhone != null)
                              Text('โทรศัพท์: ${order.customerPhone}'),
                            if (order.notes != null)
                              Text('หมายเหตุ: ${order.notes}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _buildOrderActions(order, ref),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
        );
      },
    );
  }

  List<Widget> _buildOrderActions(Order order, WidgetRef ref) {
    List<Widget> actions = [];

    switch (order.status) {
      case OrderStatus.pending:
        actions.addAll([
          ElevatedButton(
            onPressed: () => _updateOrderStatus(ref, order.id, OrderStatus.preparing),
            child: const Text('เริ่มเตรียม'),
          ),
          ElevatedButton(
            onPressed: () => _updateOrderStatus(ref, order.id, OrderStatus.cancelled),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ยกเลิก'),
          ),
        ]);
        break;
      case OrderStatus.preparing:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(ref, order.id, OrderStatus.ready),
            child: const Text('พร้อมเสิร์ฟ'),
          ),
        );
        break;
      case OrderStatus.ready:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(ref, order.id, OrderStatus.served),
            child: const Text('เสิร์ฟแล้ว'),
          ),
        );
        break;
      default:
        break;
    }

    actions.add(
      OutlinedButton(
        onPressed: () => _showDeleteDialog(order, ref),
        child: const Text('ลบ'),
      ),
    );

    return actions;
  }

  void _updateOrderStatus(WidgetRef ref, String orderId, OrderStatus newStatus) {
    ref.read(orderProvider.notifier).updateOrderStatus(orderId, newStatus);
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'รอดำเนินการ';
      case OrderStatus.preparing: return 'กำลังเตรียม';
      case OrderStatus.ready: return 'พร้อมเสิร์ฟ';
      case OrderStatus.served: return 'เสิร์ฟแล้ว';
      case OrderStatus.cancelled: return 'ยกเลิก';
    }
  }

  String _getOrderTypeText(OrderType type) {
    switch (type) {
      case OrderType.dineIn: return 'ทานในร้าน';
      case OrderType.takeaway: return 'ห่อกลับ';
      case OrderType.delivery: return 'เดลิเวอรี่';
    }
  }

  void _showAddOrderDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement add order dialog with cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์เพิ่มคำสั่งซื้อจะพัฒนาต่อไป')),
    );
  }

  void _showDeleteDialog(Order order, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบคำสั่งซื้อ "${order.orderNumber}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(orderProvider.notifier).deleteOrder(order.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}