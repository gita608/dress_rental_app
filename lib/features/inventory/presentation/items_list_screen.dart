import 'dart:io';
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
  String? _selectedCategoryId;
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
    
    // Filter dresses based on search query and category
    final allDresses = provider.dresses;
    final filteredDresses = allDresses.where((dress) {
      // Category filter
      final matchesCategory = _selectedCategoryId == null || dress.categoryId == _selectedCategoryId;
      
      // Search filter
      final query = _searchQuery.toLowerCase();
      final matchesName = dress.name.toLowerCase().contains(query);
      final matchesSize = dress.sizes.any((s) => s.toLowerCase().contains(query));
      
      return matchesCategory && (matchesName || matchesSize);
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
          
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: _selectedCategoryId == null 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                        fontWeight: _selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                    selectedColor: theme.colorScheme.primary,
                    checkmarkColor: theme.colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                ...provider.categories.map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category.title,
                        style: TextStyle(
                          color: isSelected 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: theme.colorScheme.onPrimary,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  );
                }),
              ],
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

  Widget _buildDressThumb(Dress dress, double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: dress.imagePath != null && File(dress.imagePath!).existsSync()
          ? Image.file(File(dress.imagePath!), fit: BoxFit.cover)
          : const Icon(Icons.image, color: Colors.grey),
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
            leading: _buildDressThumb(dress, 60, 80),
            title: Text(dress.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Available sizes: ${dress.sizes.join(', ')}'),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${dress.price.toStringAsFixed(0)} / day',
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold)),
                    Text('Stock: ${dress.stock}', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: dress.stock == 0 ? Colors.red : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      )
                    ),
                  ],
                ),
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
                  child: _buildDressThumb(dress, double.infinity, double.infinity),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${dress.price.toStringAsFixed(0)} / day',
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text('Stock: ${dress.stock}', 
                            style: TextStyle(
                              fontSize: 10, 
                              color: dress.stock == 0 ? Colors.red : Colors.grey.shade600,
                            )
                          ),
                        ],
                      ),
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

