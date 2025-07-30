import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_html/html.dart' as html;

import '../../../resources/color_manager.dart' show ColorsManager;

class OrdersView extends StatefulWidget {
  final String status;

  const OrdersView({Key? key, required this.status}) : super(key: key);

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  bool _isLoading = false;

  @override
  void initState() {
    print("ST===${widget.status}");
    super.initState();
  }



  bool isLoadingExcel=false;
 void exportToExcel2(  List <DocumentSnapshot> users) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 26, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: ColorsManager.primary,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorsManager.primary, ColorsManager.primary2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                
                  if (widget.status == 'waiting') _buildOrdersWidget(),
                  if (widget.status == 'del') _buildDelOrdersWidget(),
                  if (widget.status == 'approved') _buildApprovedOrdersWidget(),
                  if (widget.status == 'refuse') _buildCanceledOrdersWidget(),
                ],
              ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.status) {
      case 'waiting':
        return 'الطلبات المعلقة';
      case 'del':
        return 'الطلبات المسلمة';
      case 'approved':
        return 'الطلبات المعتمدة';
      case 'refuse':
        return 'الطلبات الملغاة';
      default:
        return 'الطلبات';
    }
  }

  Widget _buildOrdersWidget() {
    return _buildOrderList(
      status: 'waiting',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            text: 'موافقة',
            color: Colors.green,
            onTap: () => _handleEditOrderStatus(posts, 'approved'),
          ),
          _buildActionButton(
            text: 'تم التسليم',
            color: Colors.blue,
            onTap: () => _handleEditOrderStatus(posts, 'del'),
          ),
          _buildActionButton(
            text: 'رفض',
            color: Colors.red,
            onTap: () => _handleEditOrderStatus(posts, 'refuse'),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedOrdersWidget() {
    return _buildOrderList(
      status: 'approved',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            text: 'تم التسليم',
            color: Colors.blue,
            onTap: () => _handleEditOrderStatus(posts, 'del'),
          ),
          _buildActionButton(
            text: 'رفض',
            color: Colors.red,
            onTap: () => _handleEditOrderStatus(posts, 'refuse'),
          ),
        ],
      ),
    );
  }

  Widget _buildCanceledOrdersWidget() {
    return _buildOrderList(
      status: 'refuse',
      actionButtons: (posts) => Center(
        child: _buildActionButton(
          text: 'موافقة',
          color: Colors.green,
          onTap: () => _handleEditOrderStatus(posts, 'approved'),
        ),
      ),
    );
  }

  Widget _buildDelOrdersWidget() {
    return _buildOrderList(
      status: 'del',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            text: 'موافقة',
            color: Colors.green,
            onTap: () => _handleEditOrderStatus(posts, 'approved'),
          ),
          _buildActionButton(
            text: 'رفض',
            color: Colors.red,
            onTap: () => _handleEditOrderStatus(posts, 'refuse'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditOrderStatus(DocumentSnapshot posts, String status) async {
    setState(() => _isLoading = true);
    
    // Print user email from orders
    final userEmail = posts['user_email'];
    print('User Email: $userEmail');

    // Get and print token from Users collection
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: userEmail)
          .get();
      
      if (userSnapshot.docs.isNotEmpty) {
        final token = userSnapshot.docs.first['token'];
        print('User Token: $token');
      } else {
        print('No user found with email: $userEmail');
      }
    } catch (e) {
      print('Error fetching user token: $e');
    }

    // Update order status
    await _editOrderStatus(posts: posts, status: status);
    setState(() => _isLoading = false);
  }

  Future<void> _editOrderStatus({
    required DocumentSnapshot posts,
    required String status,
  }) async {
    final CollectionReference updates =
        FirebaseFirestore.instance.collection('orders');
    await updates
        .where('order_id', isEqualTo: posts['order_id'])
        .get()
        .then((snapshot) {
      snapshot.docs.last.reference.update({
        'status': status,
      }).then((value) {
        print("Order status updated to $status");
      });
    });
  }

  Widget _buildOrderList({
    required String status,
    required Widget Function(DocumentSnapshot) actionButtons,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'لا توجد طلبات',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            DocumentSnapshot posts = snapshot.data!.docs[index];
            List order = posts['order'];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(posts),
                    const SizedBox(height: 12),
                    _buildCustomerInfo(posts),
                    const SizedBox(height: 12),
                    _buildAddressInfo(posts),
                    const Divider(height: 20, thickness: 1),
                    _buildOrderDateAndTime(posts),
                    const SizedBox(height: 12),
                    _buildOrderItemsHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: _buildOrderItems(order)),
                      ),
                    ),
                    _buildOrderTotal(posts),
                    const SizedBox(height: 12),
                    _buildOrderStatus(posts),
                    const SizedBox(height: 12),
                    actionButtons(posts),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderHeader(DocumentSnapshot posts) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorsManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'رقم الطلب:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            posts['order_id'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(DocumentSnapshot posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات العميل',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('البريد الإلكتروني', posts['user_email']),
        const SizedBox(height: 8),
        _buildInfoRow('الاسم', posts['user_name']),
      ],
    );
  }

  Widget _buildAddressInfo(DocumentSnapshot posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات العنوان',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('العنوان', posts['address']),
        const SizedBox(height: 8),
        _buildInfoRow('الهاتف', posts['phone']),
      ],
    );
  }

  Widget _buildOrderDateAndTime(DocumentSnapshot posts) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: ColorsManager.primary),
              const SizedBox(width: 8),
              const Text(
                'تاريخ الطلب:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(posts['date'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: ColorsManager.primary),
              const SizedBox(width: 8),
              const Text(
                'وقت الطلب:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(posts['time'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsHeader() {
    return const Text(
      'عناصر الطلب',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  List<Widget> _buildOrderItems(List order) {
    return List.generate(order.length, (i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order[i]['image'],
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 60,
                  width: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order[i]['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order[i]['price']} ر.س',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              "x${order[i]['quant']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderTotal(DocumentSnapshot posts) {
    return Center(
      child: Text(
        "الإجمالي: ${posts['total']} ر.س",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primary,
        ),
      ),
    );
  }

  Widget _buildOrderStatus(DocumentSnapshot posts) {
    String status = '';
    if (posts['status'] == 'refuse') {
      status = 'ملغى';
    } else if (posts['status'] == 'approved') {
      status = 'معتمد';
    } else if (posts['status'] == 'del') {
      status = 'تم التسليم';
    } else if (posts['status'] == 'waiting') {
      status = 'بانتظار الموافقة';
    }

    return Column(
      children: [
        const Text(
          'حالة الطلب',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(posts['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(posts['status']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'refuse':
        return Colors.red;
      case 'approved':
        return Colors.green;
      case 'del':
        return Colors.blue;
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}