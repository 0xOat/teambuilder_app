import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/debouncer.dart';
import '../core/storage_keys.dart';
import '../models/pokemon.dart';
import '../models/pokemon_team.dart';
import '../services/poke_api_service.dart';

class PokemonController extends GetxController {
  final box = GetStorage();
  final api = PokeApiService();

  final isLoading = false.obs;
  final error = RxnString();

  final allPokemon = <Pokemon>[]; // base list
  final filteredPokemon = <Pokemon>[].obs; // displayed list

  final teams = <PokemonTeam>[].obs;
  final currentTeam = Rxn<PokemonTeam>();
  final currentView = 'builder'.obs; // 'builder' | 'teams'
  final searchQuery = ''.obs;

  final _debouncer = Debouncer(milliseconds: 300);

  static const maxTeamSize = 3;

  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await api.fetchPokemonList(limit: 151);
      allPokemon
        ..clear()
        ..addAll(list);
      filteredPokemon.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchPokemon(String q) {
    searchQuery.value = q;
    _debouncer.run(() {
      if (q.isEmpty) {
        filteredPokemon.assignAll(allPokemon);
      } else {
        final lower = q.toLowerCase();
        filteredPokemon.assignAll(
          allPokemon.where((p) => p.name.toLowerCase().contains(lower)),
        );
      }
    });
  }

  // ==== Teams ====
  void _loadStoredData() {
    try {
      final storedTeams = box.read(StorageKeys.teams);
      if (storedTeams != null && storedTeams is List) {
        teams.assignAll(storedTeams
            .map((e) => PokemonTeam.fromJson(Map<String, dynamic>.from(e)))
            .toList());
      }
      final currentId = box.read(StorageKeys.currentTeamId);
      if (currentId != null) {
        final t = teams.firstWhereOrNull((e) => e.id == currentId);
        currentTeam.value = t ?? (teams.isNotEmpty ? teams.first : null);
      } else if (teams.isNotEmpty) {
        currentTeam.value = teams.first;
      }
    } catch (_) {}
  }

  void _persist() {
    box.write(StorageKeys.teams, teams.map((e) => e.toJson()).toList());
    box.write(StorageKeys.currentTeamId, currentTeam.value?.id);
  }

  void createNewTeam() {
    final nextId = (teams.isEmpty ? 1 : (teams.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1));
    final t = PokemonTeam(
      id: nextId,
      name: 'My Team $nextId',
      members: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    teams.add(t);
    currentTeam.value = t;
    _persist();
  }

  void setCurrentTeam(PokemonTeam t) {
    currentTeam.value = t;
    _persist();
  }

  void renameTeam(int id, String name) {
    final idx = teams.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    teams[idx] = teams[idx].copyWith(name: name);
    teams.refresh();
    _persist();
  }

  void deleteTeam(int id) {
    teams.removeWhere((e) => e.id == id);
    if (currentTeam.value?.id == id) {
      currentTeam.value = teams.isNotEmpty ? teams.first : null;
    }
    _persist();
  }

  void duplicateTeam(PokemonTeam t) {
    final nextId = (teams.isEmpty ? 1 : (teams.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1));
    final copy = PokemonTeam(
      id: nextId,
      name: '${t.name} (Copy)',
      members: List.from(t.members),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    teams.add(copy);
    _persist();
  }

  // ==== Team membership ====
  bool isSelected(Pokemon p) => currentTeam.value?.members.any((e) => e.id == p.id) ?? false;

  void toggle(Pokemon p) {
    final team = currentTeam.value;
    if (team == null) return;
    final exists = team.members.any((e) => e.id == p.id);
    if (exists) {
      remove(p);
      return;
    }
    if (team.members.length >= maxTeamSize) {
      Get.snackbar('Team is full', 'Each team can have up to $maxTeamSize Pokémon.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final updated = List<Pokemon>.from(team.members)..add(p);
    _updateTeam(team.id, updated);
  }

  void remove(Pokemon p) {
    final team = currentTeam.value;
    if (team == null) return;
    final updated = List<Pokemon>.from(team.members)..removeWhere((e) => e.id == p.id);
    _updateTeam(team.id, updated);
  }

  void clearCurrentTeam() {
    final team = currentTeam.value;
    if (team == null) return;
    _updateTeam(team.id, []);
  }

  void _updateTeam(int id, List<Pokemon> members) {
    final idx = teams.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    teams[idx] = teams[idx].copyWith(members: members);
    currentTeam.value = teams[idx];
    teams.refresh();
    _persist();
  }
}