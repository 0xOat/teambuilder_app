import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pokemon_controller.dart';
import '../models/pokemon.dart';
import '../models/pokemon_team.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/team_card.dart';

class TeamBuilderPage extends GetView<PokemonController> {
  const TeamBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Obx(() => controller.currentView.value == 'teams'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.currentView.value = 'builder',
              )
            : const SizedBox.shrink()),
        title: Obx(() => Text(
              controller.currentView.value == 'teams'
                  ? 'My Teams'
                  : controller.currentTeam.value?.name ?? 'Team Builder',
            )),
        actions: [
          Obx(() => controller.currentView.value == 'teams'
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.createNewTeam,
                )
              : Row(children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showRenameDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: controller.clearCurrentTeam,
                  ),
                  IconButton(
                    icon: const Icon(Icons.group),
                    onPressed: () => controller.currentView.value = 'teams',
                  ),
                ]))
        ],
      ),
      body: Obx(() {
        if (controller.currentView.value == 'teams') {
          return _buildTeamsView(context);
        }
        return _buildBuilderView(context);
      }),
    );
  }

  Widget _buildBuilderView(BuildContext context) {
    return Column(
      children: [
        _selectedBar(),
        if (controller.currentTeam.value != null)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Obx(() => Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      'Active Team: ${controller.currentTeam.value!.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: controller.searchPokemon,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search Pokémon...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Expanded(child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value != null) {
            return Center(child: Text('Error: ${controller.error.value}'));
          }
          if (controller.filteredPokemon.isEmpty) {
            return const Center(child: Text('No Pokémon found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.78,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.filteredPokemon.length,
            itemBuilder: (_, i) => PokemonCard(pokemon: controller.filteredPokemon[i]),
          );
        })),
      ],
    );
  }

  Widget _selectedBar() {
    return Obx(() {
      final team = controller.currentTeam.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (team?.members ?? [])
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _chip(p),
                          ))
                      .toList(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'My Teams',
              onPressed: () => controller.currentView.value = 'teams',
            )
          ],
        ),
      );
    });
  }

  Widget _chip(Pokemon p) => InputChip(
        label: Text(p.name, style: const TextStyle(fontSize: 12)),
        avatar: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
        onPressed: () => controller.remove(p),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget _buildTeamsView(BuildContext context) {
    return Obx(() {
      final list = controller.teams;
      if (list.isEmpty) {
        return const Center(child: Text('No teams yet. Tap + to create.'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => TeamCard(
          team: list[i],
          isCurrent: controller.currentTeam.value?.id == list[i].id,
          onSelect: () => controller.setCurrentTeam(list[i]),
          onRename: () => _showRenameDialog(team: list[i]),
          onDuplicate: () => controller.duplicateTeam(list[i]),
          onDelete: () => _confirmDelete(list[i]),
        ),
      );
    });
  }

  void _showRenameDialog({PokemonTeam? team}) {
    final t = team ?? controller.currentTeam.value;
    if (t == null) return;
    final ctrl = TextEditingController(text: t.name);
    Get.dialog(AlertDialog(
      title: const Text('Rename Team'),
      content: TextField(controller: ctrl, autofocus: true),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            controller.renameTeam(t.id, ctrl.text.trim().isEmpty ? t.name : ctrl.text.trim());
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _confirmDelete(PokemonTeam t) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Team?'),
      content: Text('This will remove "${t.name}"'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            controller.deleteTeam(t.id);
            Get.back();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}
