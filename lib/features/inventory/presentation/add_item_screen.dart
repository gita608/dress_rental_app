import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class AddItemScreen extends StatefulWidget {
  final String? dressId;
  const AddItemScreen({super.key, this.dressId});

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
  String? _selectedImagePath;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.dressId != null) {
      final idx = provider.dresses.indexWhere((d) => d.id == widget.dressId);
      if (idx != -1) {
        _existingDress = provider.dresses[idx];
      _nameController = TextEditingController(text: _existingDress!.name);
      _priceController = TextEditingController(text: _existingDress!.price.toString());
      _descriptionController = TextEditingController(text: _existingDress!.description);
      _selectedCategoryId = _existingDress!.categoryId;
      _selectedImagePath = _existingDress!.imagePath;
      _stockController = TextEditingController(text: _existingDress!.stock.toString());
      }
    }
    if (_existingDress == null) {
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _descriptionController = TextEditingController();
      _stockController = TextEditingController(text: '1');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'dress_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dest = File('${dir.path}/$fileName');
      await dest.writeAsBytes(await image.readAsBytes());
      if (mounted) {
        setState(() => _selectedImagePath = dest.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final price = double.tryParse(_priceController.text);
      final stock = int.tryParse(_stockController.text);
      if (price == null || price <= 0 || stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid price and stock values')),
        );
        return;
      }
      if (_existingDress != null) {
        final updatedDress = _existingDress!.copyWith(
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
          categoryId: _selectedCategoryId,
          stock: stock,
          imagePath: _selectedImagePath,
        );
        provider.updateDress(updatedDress);
      } else {
        final newDress = Dress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
          sizes: ['S', 'M', 'L'],
          categoryId: _selectedCategoryId,
          stock: stock,
          imagePath: _selectedImagePath,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxFormWidth(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImagePath != null
                      ? Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                            const SizedBox(height: 8),
                            Text('Tap to add photos', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
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
                    initialValue: _selectedCategoryId,
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
        ),
      ),
    );
  }
}
