

// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_app/presentation/resources/color_manager.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';

// ignore: must_be_immutable
class OrdersView extends StatefulWidget {
  final String status;

  const OrdersView({Key? key, required this.status}) : super(key: key);

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  @override
  void initState() {
    print("ST===${widget.status}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 26),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        toolbarHeight: 55,
        backgroundColor: ColorsManager.primary,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: ColorsManager.primary2,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            if (widget.status == 'waiting') OrdersWidget(),
            if (widget.status == 'del') DelOrdersWidget(),
            if (widget.status == 'approved') ApprovedOrdersWidget(),
            if (widget.status == 'refuse') CanceledOrdersWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.status) {
      case 'waiting':
        return 'Pending Orders';
      case 'del':
        return 'Delivered Orders';
      case 'approved':
        return 'Approved Orders';
      case 'refuse':
        return 'Canceled Orders';
      default:
        return 'Orders';
    }
  }

  Widget OrdersWidget() {
    return _buildOrderList(
      status: 'waiting',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            text: 'Approve',
            color: Colors.green,
            onTap: () => EditOrderStatus(posts: posts, status: 'approved'),
          ),
          _buildActionButton(
            text: 'Delivered',
            color: Colors.blue,
            onTap: () => EditOrderStatus(posts: posts, status: 'del'),
          ),
          _buildActionButton(
            text: 'Reject',
            color: Colors.red,
            onTap: () => EditOrderStatus(posts: posts, status: 'refuse'),
          ),
        ],
      ),
    );
  }

  Widget ApprovedOrdersWidget() {
    return _buildOrderList(
      status: 'approved',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            text: 'Mark as Delivered',
            color: Colors.blue,
            onTap: () => EditOrderStatus(posts: posts, status: 'del'),
          ),
          _buildActionButton(
            text: 'Reject',
            color: Colors.red,
            onTap: () => EditOrderStatus(posts: posts, status: 'refuse'),
          ),
        ],
      ),
    );
  }

  EditOrderStatus ({
    required DocumentSnapshot posts,required String status})async{
    final CollectionReference _updates =
    FirebaseFirestore.instance.collection('orders');
    await _updates
        .where('order_id', isEqualTo: posts['order_id'])
        .get().then((snapshot) {
      snapshot.docs.last.reference.update({
        'status':status,
        // 'rate': 0.0,
      }).then((value) {
        //  appMessage(text: 'تم تعديل الحالة بنجاح ');
        // Get.offAll(const AdminView());
        print("EDITED");
      });
    });
  }
  Widget CanceledOrdersWidget() {
    return _buildOrderList(
      status: 'refuse',
      actionButtons: (posts) => Center(
        child: _buildActionButton(
          text: 'Approve',
          color: Colors.green,
          onTap: () => EditOrderStatus(posts: posts, status: 'approved'),
        ),
      ),
    );
  }

  Widget DelOrdersWidget() {
    return _buildOrderList(
      status: 'del',
      actionButtons: (posts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            text: 'Approve',
            color: Colors.green,
            onTap: () => EditOrderStatus(posts: posts, status: 'approved'),
          ),
          _buildActionButton(
            text: 'Reject',
            color: Colors.red,
            onTap: () => EditOrderStatus(posts: posts, status: 'refuse'),
          ),
        ],
      ),
    );
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No orders found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot posts = snapshot.data!.docs[index];
            List order = posts['order'];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(posts),
                    const SizedBox(height: 16),
                    _buildCustomerInfo(posts),
                    const SizedBox(height: 16),
                    _buildAddressInfo(posts),
                    const Divider(height: 24, thickness: 1),
                    _buildOrderDateAndTime(posts),
                    const SizedBox(height: 16),
                    _buildOrderItemsHeader(),
                    ..._buildOrderItems(order),
                    const SizedBox(height: 16),
                    _buildOrderTotal(posts),
                    const SizedBox(height: 16),
                    _buildOrderStatus(posts),
                    const SizedBox(height: 16),
                    actionButtons(posts),
                    if (posts['status'] != 'waiting') ...[
                      const SizedBox(height: 8),
                      _buildDeleteButton(posts),
                    ],
                    const SizedBox(height: 8),
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
    return Column(
      children: [
        const Text(
          'Order ID:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          posts['order_id'],
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(DocumentSnapshot posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Email', posts['user_email']),
        const SizedBox(height: 8),
        _buildInfoRow('Name', posts['user_name']),
      ],
    );
  }

  Widget _buildAddressInfo(DocumentSnapshot posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Address', posts['address']),
        const SizedBox(height: 8),
        _buildInfoRow('Phone', posts['phone']),
      ],
    );
  }

  Widget _buildOrderDateAndTime(DocumentSnapshot posts) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Order Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(posts['date'] ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Order Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(posts['time'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItemsHeader() {
    return const Text(
      'Order Items',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildOrderItems(List order) {
    return List.generate(order.length, (i) {
      return Column(
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order[i]['image'],
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order[i]['price']} EGP',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "x${order[i]['quant']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
        ],
      );
    });
  }

  Widget _buildOrderTotal(DocumentSnapshot posts) {
    return Center(
      child: Text(
        "Total: ${posts['total']} EGP",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primary,
        ),
      ),
    );
  }

  Widget _buildOrderStatus(DocumentSnapshot posts) {
    String status = '';
    if (posts['status'] == 'refuse') {
      status = 'Canceled';
    } else if (posts['status'] == 'approved') {
      status = 'Approved';
    } else if (posts['status'] == 'del') {
      status = 'Delivered';
    } else if (posts['status'] == 'waiting') {
      status = 'Pending Approval';
    }

    return Column(
      children: [
        const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getStatusColor(posts['status']),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(DocumentSnapshot posts) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        //onPressed: () => DeleteDataInFireBase(posts: posts),
        onPressed: () {  },
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
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

// Keep your existing helper functions (DeleteDataInFireBase and EditOrderStatus) unchanged