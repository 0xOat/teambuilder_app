import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการหมวดหมู่'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: categories.when(
        data: (categoryList) => ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            return ListTile(
              title: Text(category.name),
              subtitle: category.description != null 
                  ? Text(category.description!)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: category.isActive,
                    onChanged: (value) {
                      // TODO: Update active status
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
                        _showEditDialog(context, ref, category);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, ref, category);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('เกิดข้อผิดพลาด: $error')),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มหมวดหมู่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'ชื่อหมวดหมู่'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'คำอธิบาย'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final category = Category(
                id: '',
                name: nameController.text,
                description: descController.text.isEmpty ? null : descController.text,
                isActive: true,
                created: DateTime.now(),
                updated: DateTime.now(),
              );
              ref.read(categoryProvider.notifier).addCategory(category);
              Navigator.pop(context);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขหมวดหมู่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'ชื่อหมวดหมู่'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'คำอธิบาย'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCategory = Category(
                id: category.id,
                name: nameController.text,
                description: descController.text.isEmpty ? null : descController.text,
                isActive: category.isActive,
                created: category.created,
                updated: DateTime.now(),
              );
              ref.read(categoryProvider.notifier).updateCategory(category.id, updatedCategory);
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบหมวดหมู่ "${category.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
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