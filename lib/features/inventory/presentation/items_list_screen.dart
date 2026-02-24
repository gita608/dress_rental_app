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
            icon: Icon(provider.viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list),
            onPressed: () {
              provider.setViewMode(provider.viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list);
            },
            tooltip: 'Switch View',
          ),
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
              : provider.viewMode == ViewMode.list 
                ? _buildListView(filteredDresses, allDresses, theme, provider)
                : _buildGridView(filteredDresses, allDresses, theme, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Dress> filteredDresses, List<Dress> allDresses, ThemeData theme, AppProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredDresses.length,
      itemBuilder: (context, index) {
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
            trailing: _buildPopupMenu(context, provider, dress, realIndex),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: realIndex);
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Dress> filteredDresses, List<Dress> allDresses, ThemeData theme, AppProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredDresses.length,
      itemBuilder: (context, index) {
        final dress = filteredDresses[index];
        final realIndex = allDresses.indexOf(dress);
        
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: realIndex);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dress.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildPopupMenu(context, provider, dress, realIndex, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('₹${dress.price.toStringAsFixed(0)} / day',
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Sizes: ${dress.sizes.join(', ')}', 
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, AppProvider provider, Dress dress, int realIndex, {double size = 24}) {
    return PopupMenuButton<String>(
      iconSize: size,
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.pushNamed(context, AppRoutes.addItem, arguments: realIndex);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, provider, dress);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(Icons.more_vert, size: size),
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
              Navigator.pop(context);
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
}

