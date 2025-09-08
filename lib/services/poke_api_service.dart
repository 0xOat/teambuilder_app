import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const base = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> fetchPokemonList({int limit = 151}) async {
    final url = Uri.parse('$base/pokemon?limit=$limit');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Fetch failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results.asMap().entries.map((e) {
      final idx = e.key + 1; // PokeAPI index starts at 1 with this list
      final name = (e.value['name'] as String);
      return Pokemon.fromIdName(idx, name);
    }).toList();
  }

  Future<Map<String, dynamic>> fetchPokemonDetail(String name) async {
    final url = Uri.parse('$base/pokemon/${name.toLowerCase()}');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch details for $name');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}