import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/food_provider.dart';
import '../providers/category_provider.dart';
import '../models/food.dart';
import '../models/category.dart';

class FoodsScreen extends ConsumerStatefulWidget {
  const FoodsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends ConsumerState<FoodsScreen> {
  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodProvider);
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการรายการอาหาร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          categories.when(
            data: (categoryList) => Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('ทั้งหมด'),
                    selected: selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategoryId = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categoryList.map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategoryId = selected ? category.id : null;
                        });
                      },
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
          const Divider(),
          // Foods List
          Expanded(
            child: foods.when(
              data: (foodList) {
                final filteredFoods = selectedCategoryId == null
                    ? foodList
                    : foodList.where((food) => food.categoryId == selectedCategoryId).toList();

                if (filteredFoods.isEmpty) {
                  return const Center(child: Text('ไม่มีรายการอาหาร'));
                }

                return ListView.builder(
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: food.images.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'http://127.0.0.1:8090/api/files/foods/${food.id}/${food.images.first}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.restaurant, size: 60),
                                ),
                              )
                            : const Icon(Icons.restaurant, size: 60),
                        title: Text(food.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (food.description != null) Text(food.description!),
                            Text('ราคา: ${food.price.toStringAsFixed(0)}฿'),
                            if (food.spicyLevel != null)
                              Text('ความเผ็ด: ${_getSpicyLevelText(food.spicyLevel!)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: food.isAvailable,
                              onChanged: (value) {
                                // TODO: Update availability
                              },
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('แก้ไข'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('ลบ'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(context, ref, food);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, ref, food);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
            ),
          ),
        ],
      ),
    );
  }

  String _getSpicyLevelText(String level) {
    switch (level) {
      case 'mild': return 'ไม่เผ็ด';
      case 'medium': return 'เผ็ดปานกลาง';
      case 'hot': return 'เผ็ด';
      case 'extra_hot': return 'เผ็ดมาก';
      default: return level;
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoryProvider).value ?? [];
    _showFoodDialog(context, ref, null, categories);
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Food food) {
    final categories = ref.read(categoryProvider).value ?? [];
    _showFoodDialog(context, ref, food, categories);
  }

  void _showFoodDialog(BuildContext context, WidgetRef ref, Food? food, List<Category> categories) {
    final nameController = TextEditingController(text: food?.name);
    final descController = TextEditingController(text: food?.description);
    final priceController = TextEditingController(text: food?.price.toString());
    final ingredientsController = TextEditingController(text: food?.ingredients);
    
    // ตรวจสอบว่า categoryId ที่มีอยู่ยังมีใน categories หรือไม่
    String? selectedCategoryId = food?.categoryId;
    if (selectedCategoryId != null && 
        !categories.any((cat) => cat.id == selectedCategoryId)) {
      selectedCategoryId = null; // Reset ถ้าไม่พบใน list
    }
    
    // ตรวจสอบ spicy level
    String? selectedSpicyLevel = food?.spicyLevel;
    final validSpicyLevels = ['mild', 'medium', 'hot', 'extra_hot'];
    if (selectedSpicyLevel != null && 
        !validSpicyLevels.contains(selectedSpicyLevel)) {
      selectedSpicyLevel = null; // Reset ถ้าไม่ valid
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(food == null ? 'เพิ่มรายการอาหาร' : 'แก้ไขรายการอาหาร'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ชื่ออาหาร'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'คำอธิบาย'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(labelText: 'ส่วนผสม'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                  hint: const Text('เลือกหมวดหมู่'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('เลือกหมวดหมู่'),
                    ),
                    ...categories.map((category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'กรุณาเลือกหมวดหมู่';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSpicyLevel,
                  decoration: const InputDecoration(labelText: 'ความเผ็ด'),
                  hint: const Text('เลือกความเผ็ด'),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null, 
                      child: Text('ไม่ระบุ')
                    ),
                    DropdownMenuItem(
                      value: 'mild', 
                      child: Text('ไม่เผ็ด')
                    ),
                    DropdownMenuItem(
                      value: 'medium', 
                      child: Text('เผ็ดปานกลาง')
                    ),
                    DropdownMenuItem(
                      value: 'hot', 
                      child: Text('เผ็ด')
                    ),
                    DropdownMenuItem(
                      value: 'extra_hot', 
                      child: Text('เผ็ดมาก')
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSpicyLevel = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    selectedCategoryId != null) {
                  
                  final foodData = Food(
                    id: food?.id ?? '',
                    name: nameController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    categoryId: selectedCategoryId!,
                    ingredients: ingredientsController.text.isEmpty ? null : ingredientsController.text,
                    spicyLevel: selectedSpicyLevel,
                    isAvailable: food?.isAvailable ?? true,
                    created: food?.created ?? DateTime.now(),
                    updated: DateTime.now(),
                  );

                  if (food == null) {
                    ref.read(foodProvider.notifier).addFood(foodData);
                  } else {
                    ref.read(foodProvider.notifier).updateFood(food.id, foodData);
                  }
                  
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                  );
                }
              },
              child: Text(food == null ? 'เพิ่ม' : 'บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Food food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบอาหาร "${food.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(foodProvider.notifier).deleteFood(food.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
