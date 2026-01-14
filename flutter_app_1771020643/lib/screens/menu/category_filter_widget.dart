// lib/screens/menu/category_filter_widget.dart
import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool? isVegetarian;
  final bool? isSpicy;
  final Function(String?) onCategoryChanged;
  final Function(bool?) onVegetarianChanged;
  final Function(bool?) onSpicyChanged;
  final VoidCallback onClearFilters;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isVegetarian,
    required this.isSpicy,
    required this.onCategoryChanged,
    required this.onVegetarianChanged,
    required this.onSpicyChanged,
    required this.onClearFilters,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  bool _showFilters = false;

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'Appetizer':
        return 'Khai vị';
      case 'Main Course':
        return 'Món chính';
      case 'Dessert':
        return 'Tráng miệng';
      case 'Beverage':
        return 'Đồ uống';
      case 'Soup':
        return 'Súp';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Filters (hidden by default)
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh mục
                  const Text(
                    'Danh mục',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected: widget.selectedCategory == null,
                        onSelected: (selected) {
                          widget.onCategoryChanged(null);
                        },
                      ),
                      ...widget.categories.map((category) {
                        return FilterChip(
                          label: Text(_getCategoryDisplayName(category)),
                          selected: widget.selectedCategory == category,
                          onSelected: (selected) {
                            widget.onCategoryChanged(
                              selected ? category : null,
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Chế độ ăn
                  const Text(
                    'Chế độ ăn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 16),
                            SizedBox(width: 4),
                            Text('Chay'),
                          ],
                        ),
                        selected: widget.isVegetarian == true,
                        onSelected: (selected) {
                          widget.onVegetarianChanged(
                            widget.isVegetarian == true ? null : true,
                          );
                        },
                      ),
                      FilterChip(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, size: 16),
                            SizedBox(width: 4),
                            Text('Cay'),
                          ],
                        ),
                        selected: widget.isSpicy == true,
                        onSelected: (selected) {
                          widget.onSpicyChanged(
                            widget.isSpicy == true ? null : true,
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Clear filters button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onClearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Xóa bộ lọc'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}