import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/pocketbase_service.dart';

final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  final _pbService = PocketBaseService();

  @override
  Future<List<Category>> build() async {
    return loadCategories();
  }

  Future<List<Category>> loadCategories() async {
    try {
      final categories = await _pbService.getList<Category>(
        'categories',
        Category.fromJson,
        sort: '-created',
      );
      return categories;
    } catch (error) {
      throw error;
    }
  }

  Future<void> addCategory(Category category) async {
    state = const AsyncValue.loading();
    
    try {
      final newCategory = await _pbService.create<Category>(
        'categories',
        category.toJson(),
        Category.fromJson,
      );
      
      if (newCategory != null) {
        final currentCategories = await future;
        state = AsyncValue.data([newCategory, ...currentCategories]);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateCategory(String id, Category category) async {
    try {
      // ตรวจสอบว่า record ยังมีอยู่หรือไม่
      final existingCategory = await _pbService.getOne<Category>(
        'categories',
        id,
        Category.fromJson,
      );
      
      if (existingCategory == null) {
        print('Category not found: $id');
        // Refresh data
        state = AsyncValue.data(await loadCategories());
        return;
      }
      
      final updatedCategory = await _pbService.update<Category>(
        'categories',
        id,
        category.toJson(),
        Category.fromJson,
      );
      
      if (updatedCategory != null) {
        final currentCategories = await future;
        final updatedList = currentCategories
            .map((c) => c.id == id ? updatedCategory : c)
            .toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (error) {
      print('Update category error: $error');
      state = AsyncValue.data(await loadCategories());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final success = await _pbService.delete('categories', id);
      
      if (success) {
        final currentCategories = await future;
        final filteredList = currentCategories.where((c) => c.id != id).toList();
        state = AsyncValue.data(filteredList);
      }
    } catch (error) {
      print('Delete category error: $error');
      state = AsyncValue.data(await loadCategories());
    }
  }
}