import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.isCurrent,
    required this.onSelect,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    required this.onDetail,
  });

  final PokemonTeam team;
  final bool isCurrent;
  final VoidCallback onSelect;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect, // แตะทั้งการ์ด = Activate
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // วิทยุโชว์สถานะ Active
                  Radio<bool>(
                    value: true,
                    groupValue: isCurrent,
                    onChanged: (_) => onSelect(),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            team.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      switch (v) {
                        case 'activate':
                          onSelect();
                          break;
                        case 'rename':
                          onRename();
                          break;
                        case 'duplicate':
                          onDuplicate();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                        case 'detail':
                          onDetail();
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'activate', child: Text('Set Active')),
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                      PopupMenuItem(value: 'detail', child: Text('Detail')),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (team.members.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: team.members.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: team.members[i].imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Text('No members yet'),

              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${team.members.length} member(s)', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  const Spacer(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
