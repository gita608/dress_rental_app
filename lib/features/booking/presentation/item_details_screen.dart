import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/routing/app_routes.dart';

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
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
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
                      _buildDressStatusBadge(dress.status),
                      TextButton.icon(
                        onPressed: () => _showDressStatusSheet(context, provider, dress),
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Update Status', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Description', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'A stunning, floor-length gown featuring intricate lacework and a flowing silhouette. Perfect for formal events, weddings, or galas.',
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
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.measurementForm, arguments: dress.id);
            },
            child: const Text('Book & Enter Measurements'),
          ),
        ),
      ),
    );
  }

  Widget _buildDressStatusBadge(DressStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case DressStatus.available:
        color = Colors.green;
        label = 'Available Now';
        icon = Icons.check_circle;
        break;
      case DressStatus.cleaning:
        color = Colors.blue;
        label = 'In Cleaning';
        icon = Icons.water_drop;
        break;
      case DressStatus.repair:
        color = Colors.orange;
        label = 'In Repair';
        icon = Icons.build_circle;
        break;
      case DressStatus.rented:
        color = Colors.red;
        label = 'Rented Out';
        icon = Icons.remove_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
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
