import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/status_badge.dart';

class ItemDetailsScreen extends StatelessWidget {
  final int itemIndex;

  const ItemDetailsScreen({super.key, required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    
    // Check if index is valid
    if (itemIndex >= provider.dresses.length) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }

    final dress = provider.dresses[itemIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(dress.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addItem, arguments: itemIndex);
            },
            tooltip: 'Edit Dress',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, provider, dress),
            tooltip: 'Delete Dress',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image Placeholder
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          dress.name,
                          style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${dress.price.toStringAsFixed(0)} / day',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Badge and Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusBadge(status: dress.status),
                          const SizedBox(height: 4),
                          Text('Available Stock: ${dress.stock}', 
                            style: TextStyle(
                              color: dress.stock == 0 ? Colors.red : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _showRefillDialog(context, provider, dress),
                            icon: const Icon(Icons.add_business_outlined, size: 16),
                            label: const Text('Refill', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton.icon(
                            onPressed: () => _showDressStatusSheet(context, provider, dress),
                            icon: const Icon(Icons.sync, size: 16),
                            label: const Text('Status', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Description', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    dress.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Available Sizes', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: ['S', 'M', 'L'].map((size) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(size, style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: dress.stock > 0 && dress.status == DressStatus.available
              ? () {
                  Navigator.pushNamed(context, AppRoutes.measurementForm, arguments: dress.id);
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: dress.stock > 0 && dress.status == DressStatus.available 
                ? theme.primaryColor 
                : Colors.grey,
            ),
            child: Text(dress.stock > 0 && dress.status == DressStatus.available
              ? 'Book & Enter Measurements'
              : dress.stock == 0 ? 'Out of Stock' : 'Not Available'),
          ),
        ),
      ),
    );
  }

  void _showDressStatusSheet(BuildContext context, AppProvider provider, Dress dress) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Dress Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _statusOption(context, provider, dress, 'Available', DressStatus.available, Colors.green),
              _statusOption(context, provider, dress, 'Cleaning', DressStatus.cleaning, Colors.blue),
              _statusOption(context, provider, dress, 'Repair', DressStatus.repair, Colors.orange),
              _statusOption(context, provider, dress, 'Rented', DressStatus.rented, Colors.red),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppProvider provider, Dress dress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${dress.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDress(dress.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to catalog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showRefillDialog(BuildContext context, AppProvider provider, Dress dress) {
    final controller = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refill Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: ${dress.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Amount to add'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                provider.refillStock(dress.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$amount items added to stock')),
                );
              }
            },
            child: const Text('REFILL'),
          ),
        ],
      ),
    );
  }

  Widget _statusOption(BuildContext context, AppProvider provider, Dress dress, String label, DressStatus status, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(Icons.circle, color: color, size: 12)),
      title: Text(label),
      onTap: () {
        provider.updateDressStatus(dress.id, status);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dress status updated to: $label')),
        );
      },
    );
  }
}
