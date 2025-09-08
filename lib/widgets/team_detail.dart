import 'package:flutter/material.dart';
import '../models/pokemon_team.dart';

class TeamDetailPage extends StatelessWidget {
  final PokemonTeam team;

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: team.members.isEmpty
            ? const Center(child: Text("No Pokémon in this team."))
            : ListView.builder(
                itemCount: team.members.length,
                itemBuilder: (context, index) {
                  final p = team.members[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(p.imageUrl),
                      ),
                      title: Text(p.name),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
