import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class AddItemScreen extends StatefulWidget {
  final int? itemIndex;
  const AddItemScreen({super.key, this.itemIndex});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  Dress? _existingDress;
  String? _selectedCategoryId;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.itemIndex != null) {
      _existingDress = provider.dresses[widget.itemIndex!];
      _nameController = TextEditingController(text: _existingDress!.name);
      _priceController = TextEditingController(text: _existingDress!.price.toString());
      _descriptionController = TextEditingController(text: _existingDress!.description);
      _selectedCategoryId = _existingDress!.categoryId;
      _stockController = TextEditingController(text: _existingDress!.stock.toString());
    } else {
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _descriptionController = TextEditingController();
      _stockController = TextEditingController(text: '1');
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      if (_existingDress != null) {
        final updatedDress = Dress(
          id: _existingDress!.id,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          sizes: _existingDress!.sizes,
          categoryId: _selectedCategoryId,
          stock: int.parse(_stockController.text),
          status: _existingDress!.status,
        );
        provider.updateDress(updatedDress);
      } else {
        final newDress = Dress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          sizes: ['S', 'M', 'L'], // Default for now
          categoryId: _selectedCategoryId,
          stock: int.parse(_stockController.text),
        );
        provider.addDress(newDress);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_existingDress != null ? 'Item updated successfully' : 'Item added successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingDress != null ? 'Edit Dress' : 'Add New Dress'),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Placeholder for image upload
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                    const SizedBox(height: 8),
                    Text('Tap to add photos', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Dress Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Rental Price (per day)', prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Initial Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter stock count';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final categories = provider.categories;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please select a category';
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
