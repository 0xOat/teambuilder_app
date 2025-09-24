import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/realtime_order_provider.dart';

class RealtimeNotifications extends ConsumerWidget {
  const RealtimeNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realtimeState = ref.watch(realtimeOrderProvider);

    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          Icon(
            Icons.notifications,
            color: realtimeState.isConnected ? Colors.green : Colors.red,
          ),
          if (realtimeState.notifications.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${realtimeState.notifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      itemBuilder: (context) {
        if (realtimeState.notifications.isEmpty) {
          return [
            const PopupMenuItem<String>(
              value: 'empty',
              enabled: false,
              child: Text('ไม่มีการแจ้งเตือน'),
            ),
          ];
        }

        return [
          PopupMenuItem<String>(
            value: 'header',
            enabled: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'การแจ้งเตือน',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(realtimeOrderProvider.notifier).clearAllNotifications();
                    Navigator.pop(context);
                  },
                  child: const Text('ล้างทั้งหมด'),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          ...realtimeState.notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final notification = entry.value;
            
            return PopupMenuItem<String>(
              value: 'notification_$index',
              child: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            ref.read(realtimeOrderProvider.notifier).clearNotification(index);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Text(
                      notification.message,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm:ss').format(notification.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ];
      },
      onSelected: (value) {
        if (value.startsWith('notification_')) {
          // Handle notification tap
          final index = int.parse(value.split('_')[1]);
          final notification = realtimeState.notifications[index];
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notification.message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}