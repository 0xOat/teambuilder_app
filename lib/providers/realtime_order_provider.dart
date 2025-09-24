import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/realtime_service.dart';
import '../services/pocketbase_service.dart';
import 'order_provider.dart';

final realtimeOrderProvider = NotifierProvider<RealtimeOrderNotifier, RealtimeOrderState>(RealtimeOrderNotifier.new);

class RealtimeOrderNotifier extends Notifier<RealtimeOrderState> {
  final _realtimeService = RealtimeService();
  final _pbService = PocketBaseService();

  @override
  RealtimeOrderState build() {
    _initializeRealtime();
    return RealtimeOrderState.initial();
  }

  Future<void> _initializeRealtime() async {
    state = state.copyWith(isConnected: false);

    try {
      // Subscribe to orders collection
      await _realtimeService.subscribeToCollection(
        'orders',
        _handleOrderUpdate,
      );

      // Subscribe to order_items collection
      await _realtimeService.subscribeToCollection(
        'order_items',
        _handleOrderItemUpdate,
      );

      state = state.copyWith(isConnected: true);
      print('🔄 Real-time updates initialized');
    } catch (error) {
      state = state.copyWith(
        isConnected: false,
        errorMessage: 'Failed to connect to real-time updates',
      );
      print('❌ Real-time initialization failed: $error');
    }
  }

  void _handleOrderUpdate(RealtimeEvent event) {
    print('📦 Order ${event.action}: ${event.record?['id']}');
    
    final notification = RealtimeNotification(
      type: 'order',
      action: event.action,
      title: _getOrderNotificationTitle(event.action),
      message: _getOrderNotificationMessage(event),
      timestamp: event.timestamp,
      data: event.record,
    );

    // Add notification to state
    state = state.copyWith(
      notifications: [notification, ...state.notifications.take(9).toList()],
      lastUpdate: event.timestamp,
    );

    // Refresh order provider data
    ref.read(orderProvider.notifier).refreshOrders();
  }

  void _handleOrderItemUpdate(RealtimeEvent event) {
    print('🍽️ Order item ${event.action}: ${event.record?['id']}');
    
    // Refresh orders when order items change
    ref.read(orderProvider.notifier).refreshOrders();
  }

  String _getOrderNotificationTitle(String action) {
    switch (action) {
      case 'create':
        return '🆕 คำสั่งซื้อใหม่';
      case 'update':
        return '📝 อัปเดตคำสั่งซื้อ';
      case 'delete':
        return '🗑️ ลบคำสั่งซื้อ';
      default:
        return '📦 คำสั่งซื้อ';
    }
  }

  String _getOrderNotificationMessage(RealtimeEvent event) {
    final record = event.record;
    if (record == null) return 'ไม่มีข้อมูล';

    switch (event.action) {
      case 'create':
        return 'คำสั่งซื้อใหม่: ${record['order_number']} - ${record['customer_name']}';
      case 'update':
        return 'อัปเดต: ${record['order_number']} - สถานะ: ${record['status']}';
      case 'delete':
        return 'ลบคำสั่งซื้อ: ${record['order_number']}';
      default:
        return 'คำสั่งซื้อ: ${record['order_number']}';
    }
  }

  void clearNotification(int index) {
    final notifications = List<RealtimeNotification>.from(state.notifications);
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      state = state.copyWith(notifications: notifications);
    }
  }

  void clearAllNotifications() {
    state = state.copyWith(notifications: []);
  }

  Future<void> reconnect() async {
    await _realtimeService.unsubscribeAll();
    await _initializeRealtime();
  }
}

class RealtimeOrderState {
  final bool isConnected;
  final List<RealtimeNotification> notifications;
  final DateTime? lastUpdate;
  final String? errorMessage;

  RealtimeOrderState({
    required this.isConnected,
    required this.notifications,
    this.lastUpdate,
    this.errorMessage,
  });

  factory RealtimeOrderState.initial() {
    return RealtimeOrderState(
      isConnected: false,
      notifications: [],
    );
  }

  RealtimeOrderState copyWith({
    bool? isConnected,
    List<RealtimeNotification>? notifications,
    DateTime? lastUpdate,
    String? errorMessage,
  }) {
    return RealtimeOrderState(
      isConnected: isConnected ?? this.isConnected,
      notifications: notifications ?? this.notifications,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      errorMessage: errorMessage,
    );
  }
}

class RealtimeNotification {
  final String type;
  final String action;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  RealtimeNotification({
    required this.type,
    required this.action,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });
}