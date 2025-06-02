

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/views/admin/products/product_details.dart';


class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String? selectedCategory;
  String? selectedCategoryName;
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cat')
          .orderBy('nameAr')
          .get();
      
      setState(() {
        categories = snapshot.docs.map((doc) => {
          'id': doc.id,
          'nameAr': doc['nameAr'] ?? 'غير محدد',
        }).toList();
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      debugPrint('Error loading categories: $e');
    }
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryBottomSheet(
        categories: categories,
        selectedCategory: selectedCategory,
        onCategorySelected: (categoryId, categoryName) {
          setState(() {
            selectedCategory = categoryId;
            selectedCategoryName = categoryName;
          });
          Navigator.pop(context);
        },
        onClearFilter: () {
          setState(() {
            selectedCategory = null;
            selectedCategoryName = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 56,
        title: const Text(
          'المنتجات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue, // Change to your primary color
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: isLoadingCategories ? null : _showCategoryBottomSheet,
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (selectedCategory != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (selectedCategory != null) _buildFilterChip(),
          Expanded(
            child: ProductWidget(
              selectedCategory: selectedCategory,
              selectedCategoryName: selectedCategoryName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Chip(
            label: Text(
              selectedCategoryName ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.blue.withOpacity(0.1),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                selectedCategory = null;
                selectedCategoryName = null;
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                selectedCategory = null;
                selectedCategoryName = null;
              });
            },
            child: const Text(
              'مسح الفلتر',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String categoryId, String categoryName) onCategorySelected;
  final VoidCallback onClearFilter;

  const CategoryBottomSheet({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onClearFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'تصفية حسب الفئة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (selectedCategory != null)
                  TextButton(
                    onPressed: onClearFilter,
                    child: const Text(
                      'مسح الفلتر',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Search field (optional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن فئة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // Implement search functionality if needed
              },
            ),
          ),
          
          // Categories list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category['id'];
                
                return ListTile(
                  title: Text(
                    category['nameAr'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 20,
                        )
                      : null,
                  onTap: () => onCategorySelected(
                    category['id'],
                    category['nameAr'],
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

class ProductWidget extends StatelessWidget {
  String? selectedCategory;
  String? selectedCategoryName;
  
   ProductWidget({
    Key? key, 
    this.selectedCategory,
    this.selectedCategoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getProductsStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (snapshot.hasError) {
          // ignore: avoid_print
          print("error==${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ ما',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // No data state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedCategory != null 
                      ? 'لا توجد منتجات في هذه الفئة'
                      : 'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (selectedCategory != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Clear filter
                      if (context.findAncestorStateOfType<_ProductsViewState>() != null) {
                        context.findAncestorStateOfType<_ProductsViewState>()!.setState(() {
                          selectedCategory = null;
                          selectedCategoryName = null;
                        });
                      }
                    },
                    child: const Text(
                      'عرض جميع المنتجات',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Success state with data
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 11,
              childAspectRatio: 1.11,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot product = snapshot.data!.docs[index];
              return ProductCard(
                product: product,
                index: index,
              );
            },
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getProductsStream() {

    print("sss=$selectedCategoryName");
    if (selectedCategory != null && selectedCategoryName != null) {
      // Filter products by the Arabic category name
      return FirebaseFirestore.instance
          .collection('products')
          .where('catAr', isEqualTo: selectedCategoryName)
          .orderBy('name')
          .snapshots();
    } else {
      // If no category selected, return all products
      return FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .snapshots();
    }
  }
}

class ProductCard extends StatelessWidget {
  final DocumentSnapshot product;
  final int index;

  const ProductCard({
    Key? key,
    required this.product,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
     clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(
            () => AdminProductDetails(
              tag: 'img$index',
              posts: product,
            ),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Hero(
              tag: 'img$index',
              child: CachedNetworkImage(
                height:222,
                imageUrl: product['image'] ?? '',
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? 'منتج غير محدد',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product Price
                  Text(
                    '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  
                  // Category (optional)
                  if (product['catAr'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product['catAr'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for AdminProductDetails (replace with your actual implementation)
