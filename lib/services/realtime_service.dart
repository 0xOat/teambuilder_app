import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final _pbService = PocketBaseService();
  final Map<String, UnsubscribeFunc> _subscriptions = {};

  PocketBase get _pb => _pbService.pb;

  // Subscribe to collection changes
  Future<void> subscribeToCollection(
    String collection,
    Function(RealtimeEvent) onUpdate,
    {String? filter}
  ) async {
    try {
      // Unsubscribe if already exists
      await unsubscribeFromCollection(collection);

      final unsubscribe = await _pb.collection(collection).subscribe(
        '*', // Listen to all events
        (e) {
          final event = RealtimeEvent(
            action: e.action,
            record: e.record?.toJson(),
            collection: collection,
            timestamp: DateTime.now(),
          );
          onUpdate(event);
        },
      );

      _subscriptions[collection] = unsubscribe;
      print('✅ Subscribed to $collection collection');
    } catch (error) {
      print('❌ Failed to subscribe to $collection: $error');
    }
  }

  // Unsubscribe from collection
  Future<void> unsubscribeFromCollection(String collection) async {
    if (_subscriptions.containsKey(collection)) {
      try {
        await _subscriptions[collection]!();
        _subscriptions.remove(collection);
        print('✅ Unsubscribed from $collection collection');
      } catch (error) {
        print('❌ Failed to unsubscribe from $collection: $error');
      }
    }
  }

  // Unsubscribe from all collections
  Future<void> unsubscribeAll() async {
    for (final collection in _subscriptions.keys.toList()) {
      await unsubscribeFromCollection(collection);
    }
  }

  // Check if subscribed to collection
  bool isSubscribed(String collection) {
    return _subscriptions.containsKey(collection);
  }

  // Get active subscriptions
  List<String> get activeSubscriptions => _subscriptions.keys.toList();
}

class RealtimeEvent {
  final String action; // 'create', 'update', 'delete'
  final Map<String, dynamic>? record;
  final String collection;
  final DateTime timestamp;

  RealtimeEvent({
    required this.action,
    this.record,
    required this.collection,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'RealtimeEvent{action: $action, collection: $collection, record: ${record?['id']}}';
  }
}