import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class ItemsListScreen extends StatelessWidget {
  final bool isTab;
  const ItemsListScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final dresses = provider.dresses;

    return Scaffold(
      appBar: isTab ? null : AppBar(
        title: const Text('Dress Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addItem);
            },
          ),
        ],
      ),
      floatingActionButton: isTab ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addItem);
        },
        child: const Icon(Icons.add),
      ) : null,
      body: dresses.isEmpty 
        ? const Center(child: Text('No dresses available. Add one!'))
        : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dresses.length,
        itemBuilder: (context, index) {
          final dress = dresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              title: Text(dress.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Available sizes: ${dress.sizes.join(', ')}'),
                  const SizedBox(height: 4),
                  Text('\$${dress.price.toStringAsFixed(0)} / day',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: index);
              },
            ),
          );
        },
      ),
    );
  }
}
