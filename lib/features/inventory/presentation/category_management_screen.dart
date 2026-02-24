import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No categories found. Add one!'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.title),
                  subtitle: Text(category.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showCategoryDialog(context, category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, provider, category),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final titleController = TextEditingController(text: category?.title);
    final descController = TextEditingController(text: category?.description);
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;
              
              final provider = Provider.of<AppProvider>(context, listen: false);
              final newCategory = Category(
                id: isEditing ? category.id : DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descController.text,
              );

              if (isEditing) {
                provider.updateCategory(newCategory);
              } else {
                provider.addCategory(newCategory);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'UPDATE' : 'SAVE'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppProvider provider, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.title}"? Items in this category will become uncategorized.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
