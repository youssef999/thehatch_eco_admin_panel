import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/views/admin/products/product_details.dart';
import 'package:universal_html/html.dart' as html;

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
    fetchProducts();
    super.initState();
    _loadCategories();
  }



bool isLoadingExcel=false;

  // This is your existing function
Future<void> exportToExcel(List<Map<String, dynamic>> productsData2) async {
  print("data===$productsData2");
  setState(() {
    isLoadingExcel = true;
  });
  try {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel["products"];

    // Add headers
    sheetObject.appendRow([
      TextCellValue('ID'),
      TextCellValue('Name'),
      TextCellValue('Name (Arabic)'),
      TextCellValue('Description'),
      TextCellValue('Description (Arabic)'),
      TextCellValue('Price'),
      TextCellValue('Category'),
      TextCellValue('Image URL'),
    ]);

    // Add data
    for (var product in productsData2) {
      sheetObject.appendRow([
        TextCellValue(product['id']?.toString() ?? ''),
        TextCellValue(product['name'] ?? ''),
        TextCellValue(product['nameAr'] ?? ''),
        TextCellValue(product['des'] ?? ''),
        TextCellValue(product['desAr'] ?? ''),
        TextCellValue(product['price']?.toString() ?? ''),
        TextCellValue(product['catAr'] ?? ''),
        TextCellValue(product['image'] ?? ''),
      ]);
    }

    // Save the Excel file
    var fileBytes = excel.save();
    if (fileBytes != null) {
      final blob = html.Blob([Uint8List.fromList(fileBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'منتجات المتجر.xlsx';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  } catch (e) {
    debugPrint('Error exporting to Excel: $e');
  } finally {
    setState(() {
      isLoadingExcel = false;
    });
  }
}


 void exportToExcel2(List<Map<String, dynamic>> users) async {
  setState(() {
    isLoadingExcel = true;
  });
  try {
    print('🚀 Starting Excel export process...');

    // First fetch all the task counts for each provider
    List<Map<String, dynamic>> userDataList = [];

    for (int i = 0; i < users.length; i++) {
      final provider = users[i];
     // final email = provider['email'];

      userDataList.add({
        'name': provider['name'],
        'nameAr': provider['nameAr'],
      //  'email': provider['email'],
      //  'image': provider['image'],
        'des': provider['des'],
        'desAr': provider['desAr'],
        'cat': provider['cat'],
        'catAr': provider['catAr'],
        'rate': provider['rate'],
      });
    }

    final arabicHeaders = LinkedHashMap<String, String>.from({
      'name': 'الاسم',
      'nameAr': 'الاسم بالعربي',
      'des': 'الوصف',
      'desAr': 'الوصف بالعربي',
      'cat': 'القسم',
      'catAr': 'القسم بالعربي',
      'rate': 'التقييم',
    });

    String jsonData = jsonEncode(userDataList.map((transaction) {
      Map<String, dynamic> converted = Map<String, dynamic>.from(transaction);
      Map<String, dynamic> translated = {};

      arabicHeaders.forEach((key, arabicKey) {
        var value = converted[key];
        translated[arabicKey] = value;
      });

      return translated;
    }).toList());

    List<dynamic> jsonList = jsonDecode(jsonData);
    print('✅ Parsed ${jsonList.length} records');

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    print('✅ Excel sheet created');

    // Define general RTL cell style
    final baseStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
    );

    // Write headers
    final headers = arabicHeaders.values.toList();
    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]); // Use TextCellValue
      cell.cellStyle = baseStyle;
    }

    print('✅ Headers written with RTL style');

    // Write data rows
    for (int row = 0; row < jsonList.length; row++) {
      final item = jsonList[row] as Map<String, dynamic>;
      for (int col = 0; col < headers.length; col++) {
        var header = headers[col];
        var value = item[header];
        var displayValue = value?.toString() ?? '';

        var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        cell.value = TextCellValue(displayValue); // Use TextCellValue
        cell.cellStyle = baseStyle;
      }
    }

    print('✅ Data rows written');

    // Export
    var bytes = excel.encode();
    if (bytes == null) {
      print('❌ Failed to encode Excel');
      return;
    }

    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "المنتجات.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);

    print('🎉 Excel file downloaded successfully!');
  } catch (e) {
    print('❌ Export failed: $e');
    print('🚨 Stack trace: ${e is Error ? e.stackTrace : ''}');
  } finally {
    setState(() {
      isLoadingExcel = false;
    });
  }
}

  List<Map<String, dynamic>> productsData = [];
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        productsData = products;
      });

      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 64,
        title: const Text(
          'المنتجات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          // Excel Export Button
          IconButton(
            onPressed: isLoadingExcel ? null : () async {
              if (productsData.isEmpty) {
                await fetchProducts();
              }
              exportToExcel2(productsData);
            },
            icon: isLoadingExcel
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 26,
                  ),
            tooltip: 'تصدير إلى Excel',
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: isLoadingCategories ? null : _showCategoryBottomSheet,
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 26,
                ),
                tooltip: 'تصفية المنتجات',
              ),
              if (selectedCategory != null)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Chip(
            label: Text(
              selectedCategoryName ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E88E5),
              ),
            ),
            backgroundColor: const Color(0xFFE3F2FD),
            deleteIcon: const Icon(Icons.close, size: 20, color: Color(0xFF1E88E5)),
            onDeleted: () {
              setState(() {
                selectedCategory = null;
                selectedCategoryName = null;
              });
            },
            padding: const EdgeInsets.symmetric(horizontal: 12),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 2,
            shadowColor: Colors.black12,
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
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'تصفية حسب الفئة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                const Spacer(),
                if (selectedCategory != null)
                  TextButton(
                    onPressed: onClearFilter,
                    child: const Text(
                      'مسح الفلتر',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن فئة...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF757575)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                // Implement search functionality if needed
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category['id'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      category['nameAr'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF212121),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1E88E5),
                            size: 22,
                          )
                        : null,
                    onTap: () => onCategorySelected(
                      category['id'],
                      category['nameAr'],
                    ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 6, // Placeholder count for loading
            itemBuilder: (context, index) => const ProductCardPlaceholder(),
          );
        }

        if (snapshot.hasError) {
          debugPrint("error==${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ ما',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedCategory != null ? 'لا توجد منتجات في هذه الفئة' : 'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                if (selectedCategory != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
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
                        color: Color(0xFF1E88E5),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.32,
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
        );
      },
    );
  }

  Stream<QuerySnapshot> _getProductsStream() {
    if (selectedCategory != null && selectedCategoryName != null) {
      return FirebaseFirestore.instance
          .collection('products')
          .where('catAr', isEqualTo: selectedCategoryName)
          .orderBy('name')
          .snapshots();
    } else {
      return FirebaseFirestore.instance.collection('products').orderBy('name').snapshots();
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => AdminProductDetails(
              tag: 'img$index',
              posts: product,
            ),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 400),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'img$index',
              child: kIsWeb
                  ? Image.network(
                      product['image'] ?? '',
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    )
                  : CachedNetworkImage(
                      height: 180,
                      imageUrl: product['image'] ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(loading: true),
                      errorWidget: (context, url, error) => _buildImagePlaceholder(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'منتج غير محدد',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  if (product['catAr'] != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      product['catAr'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      height: 180,
      color: Colors.grey[100],
      child: Center(
        child: loading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              )
            : const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 40,
              ),
      ),
    );
  }
}

class ProductCardPlaceholder extends StatelessWidget {
  const ProductCardPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 18,
                  width: 80,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 100,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}