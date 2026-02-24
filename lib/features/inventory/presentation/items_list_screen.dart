import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/app_logo.dart';

import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/app_logo.dart';

class ItemsListScreen extends StatefulWidget {
  final bool isTab;
  const ItemsListScreen({super.key, this.isTab = false});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    
    // Filter dresses based on search query (by name or finding a specific size)
    final allDresses = provider.dresses;
    final filteredDresses = _searchQuery.isEmpty 
        ? allDresses 
        : allDresses.where((dress) {
            final query = _searchQuery.toLowerCase();
            final matchesName = dress.name.toLowerCase().contains(query);
            final matchesSize = dress.sizes.any((s) => s.toLowerCase().contains(query));
            return matchesName || matchesSize;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: widget.isTab ? const AppLogo(size: 24) : const Text('Dress Catalog'),
        centerTitle: !widget.isTab,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addItem);
            },
          ),
        ],
      ),
      floatingActionButton: widget.isTab ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addItem);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ) : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search dresses or sizes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: filteredDresses.isEmpty 
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No dresses available. Add one!' : 'We couldn\'t find a match for "$_searchQuery".',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredDresses.length,
              itemBuilder: (context, index) {
                // We need to pass the *actual* index from the un-filtered list to the details screen to mutate it safely
                final dress = filteredDresses[index];
                final realIndex = allDresses.indexOf(dress);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
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
                        Text('₹${dress.price.toStringAsFixed(0)} / day',
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: realIndex);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

