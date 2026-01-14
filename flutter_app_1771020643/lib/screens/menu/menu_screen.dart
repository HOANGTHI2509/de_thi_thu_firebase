// lib/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/menu_item_repository.dart';
import '../../models/menu_item_model.dart';
import '../../widgets/menu_item_card.dart';
import './menu_item_detail_screen.dart';
import './category_filter_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuItemRepository _repository = MenuItemRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<MenuItemModel> _menuItems = [];
  List<MenuItemModel> _filteredItems = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool? _isVegetarian;
  bool? _isSpicy;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
    _loadCategories();
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _repository.getAllMenuItems();
      setState(() {
        _menuItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading menu items: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải thực đơn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _applyFilters() {
    List<MenuItemModel> result = _menuItems;

    // Áp dụng tìm kiếm
    if (_searchQuery.isNotEmpty) {
      result = result.where((item) {
        final nameMatch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final descMatch = item.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final ingredientsMatch = item.ingredients.any(
          (ingredient) => ingredient.toLowerCase().contains(_searchQuery.toLowerCase())
        );
        return nameMatch || descMatch || ingredientsMatch;
      }).toList();
    }

    // Áp dụng bộ lọc
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((item) => item.category == _selectedCategory).toList();
    }
    
    if (_isVegetarian != null) {
      result = result.where((item) => item.isVegetarian == _isVegetarian).toList();
    }
    
    if (_isSpicy != null) {
      result = result.where((item) => item.isSpicy == _isSpicy).toList();
    }

    setState(() {
      _filteredItems = result;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _isVegetarian = null;
      _isSpicy = null;
      _searchQuery = '';
      _searchController.clear();
      _filteredItems = _menuItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
          
          // Category Filter Widget
          CategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            isVegetarian: _isVegetarian,
            isSpicy: _isSpicy,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _applyFilters();
            },
            onVegetarianChanged: (value) {
              setState(() {
                _isVegetarian = value;
              });
              _applyFilters();
            },
            onSpicyChanged: (value) {
              setState(() {
                _isSpicy = value;
              });
              _applyFilters();
            },
            onClearFilters: _clearFilters,
          ),
          
          // Filter Summary
          if (_selectedCategory != null || _isVegetarian != null || _isSpicy != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFilterSummary(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Xóa bộ lọc',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          
          // Menu Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không tìm thấy món ăn',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Xóa bộ lọc'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return MenuItemCard(
                            menuItem: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuItemDetailScreen(menuItem: item),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMenuItems,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  String _getFilterSummary() {
    final filters = <String>[];
    
    if (_selectedCategory != null) {
      filters.add('Danh mục: $_selectedCategory');
    }
    if (_isVegetarian != null) {
      filters.add(_isVegetarian! ? 'Chay' : 'Mặn');
    }
    if (_isSpicy != null) {
      filters.add(_isSpicy! ? 'Cay' : 'Không cay');
    }
    
    return filters.join(' • ');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}