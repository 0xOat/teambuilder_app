import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/realtime_order_provider.dart';

class ConnectionStatus extends ConsumerWidget {
  const ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realtimeState = ref.watch(realtimeOrderProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: realtimeState.isConnected ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: realtimeState.isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            realtimeState.isConnected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: realtimeState.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            realtimeState.isConnected ? 'เชื่อมต่อแล้ว' : 'ไม่ได้เชื่อมต่อ',
            style: TextStyle(
              fontSize: 12,
              color: realtimeState.isConnected ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!realtimeState.isConnected) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                ref.read(realtimeOrderProvider.notifier).reconnect();
              },
              child: Icon(
                Icons.refresh,
                size: 16,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}