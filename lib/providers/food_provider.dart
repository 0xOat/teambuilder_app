import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food.dart';
import '../services/pocketbase_service.dart';

final foodProvider = AsyncNotifierProvider<FoodNotifier, List<Food>>(FoodNotifier.new);

final foodsByCategoryProvider = Provider.family<AsyncValue<List<Food>>, String>((ref, categoryId) {
  final foods = ref.watch(foodProvider);
  
  return foods.when(
    data: (foodList) => AsyncValue.data(
      foodList.where((food) => food.categoryId == categoryId).toList()
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class FoodNotifier extends AsyncNotifier<List<Food>> {
  final _pbService = PocketBaseService();

  @override
  Future<List<Food>> build() async {
    return loadFoods();
  }

  Future<List<Food>> loadFoods() async {
    try {
      final foods = await _pbService.getList<Food>(
        'foods',
        Food.fromJson,
        sort: '-created',
        expand: 'category',
      );
      return foods;
    } catch (error) {
      throw error;
    }
  }

  Future<void> addFood(Food food) async {
    state = const AsyncValue.loading();
    
    try {
      final newFood = await _pbService.create<Food>(
        'foods',
        food.toJson(),
        Food.fromJson,
      );
      
      if (newFood != null) {
        final currentFoods = await future;
        state = AsyncValue.data([newFood, ...currentFoods]);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateFood(String id, Food food) async {
    try {
      // ตรวจสอบว่า record ยังมีอยู่หรือไม่
      final existingFood = await _pbService.getOne<Food>(
        'foods',
        id,
        Food.fromJson,
      );
      
      if (existingFood == null) {
        print('Food not found: $id');
        // Refresh data
        state = AsyncValue.data(await loadFoods());
        return;
      }
      
      final updatedFood = await _pbService.update<Food>(
        'foods',
        id,
        food.toJson(),
        Food.fromJson,
      );
      
      if (updatedFood != null) {
        final currentFoods = await future;
        final updatedList = currentFoods
            .map((f) => f.id == id ? updatedFood : f)
            .toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (error) {
      print('Update food error: $error');
      state = AsyncValue.data(await loadFoods());
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      final success = await _pbService.delete('foods', id);
      
      if (success) {
        final currentFoods = await future;
        final filteredList = currentFoods.where((f) => f.id != id).toList();
        state = AsyncValue.data(filteredList);
      }
    } catch (error) {
      print('Delete food error: $error');
      state = AsyncValue.data(await loadFoods());
    }
  }
}