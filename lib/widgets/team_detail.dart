import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/pokemon_team.dart';
import '../services/poke_api_service.dart';

class TeamDetailPage extends StatelessWidget {
  final PokemonTeam team;
  final _api = PokeApiService();

  TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
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
                      leading: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                      title: Text(p.name),
                      subtitle: FutureBuilder<Map<String, dynamic>>(
                        future: _api.fetchPokemonDetail(p.name),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading...');
                          } else if (snapshot.hasError) {
                            return const Text('Error loading data');
                          }

                          final data = snapshot.data!;
                          final height = data['height'];
                          final weight = data['weight'];
                          final abilities = (data['abilities'] as List)
                              .map((a) => a['ability']['name'] as String)
                              .join(', ');

                          return Text(
                            'Height: $height | Weight: $weight\nAbilities: $abilities',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
