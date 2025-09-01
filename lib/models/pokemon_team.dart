import 'pokemon.dart';

class PokemonTeam {
  final int id;
  final String name;
  final List<Pokemon> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PokemonTeam({
    required this.id,
    required this.name,
    this.members = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  PokemonTeam copyWith({String? name, List<Pokemon>? members}) => PokemonTeam(
        id: id,
        name: name ?? this.name,
        members: members ?? List.from(this.members),
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PokemonTeam.fromJson(Map<String, dynamic> json) => PokemonTeam(
        id: json['id'],
        name: json['name'],
        members: (json['members'] as List)
            .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}