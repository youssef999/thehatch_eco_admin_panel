import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming you're using GetX for navigation
import 'package:shop_app/presentation/views/admin/products/add_product.dart';
import 'package:shop_app/presentation/views/admin/products/products_view.dart';

// Assuming these are defined elsewhere in your project
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import 'cat/add_cat.dart';
import 'cat/all_cat.dart';
import 'orders/orders.dart';


class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  String _selectedTab = 'dashboard'; // Default selected tab (can be any identifier)

  // Function to update the selected tab
  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  // Function to return the content based on the selected tab
  Widget _getContentForSelectedTab() {
    switch (_selectedTab) {
      case 'add_product':
        return const SizedBox(
          height: 1300, // Define a fixed height or use Expanded
          child: AddNewProduct()
        );
      //  return const AddNewProduct();
      case 'all_products':
        return const SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child: ProductsView()
        );

      case 'add_category':
        return const SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child: AddNewCat()
        );

      case 'all_categories':
        return const SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child: CatView()
        );
      case 'orders_waiting':
        return SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child: OrdersView(status: 'waiting',)
        );
      //  return OrdersView(status: 'waiting');
      case 'orders_approved':
        return SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child:OrdersView(status: 'approved')
        );

      case 'orders_delivered':
        return SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child:OrdersView(status: 'del')
        );

      case 'orders_refused':
        return SizedBox(
            height: 900, // Define a fixed height or use Expanded
            child:OrdersView(status: 'refuse')
        );

      default:
       return Center(
  child: Container(
    constraints: const BoxConstraints(
      maxWidth: 500,
      minWidth: 300,
      maxHeight: 400,
      minHeight: 200,
    ),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFF8FAFB), Color(0xFFE9EEF2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withOpacity(0.12),
          spreadRadius: 4,
          blurRadius: 24,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo with circle background and shadow
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo1.png',
            width: 64,
            height: 64,
          ),
        ),
        const SizedBox(width: 32),
        // Animated fade-in text
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: child,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة تحكم متجر',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3A3A),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'the hatch',
                  style: TextStyle(
                    fontSize: 21,
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'مرحباً بك في لوحة التحكم الخاصة بمتجرك!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100, // Light background for modern look
        body: Center(
          child: Row(
          
            children: [
              // Main Content Area (Left side for RTL or primary content)
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Header
                    Center(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "THE HATCH المتجر الالكتروني لوحة التحكم ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Image.asset(
                                AssetsManager.Logo,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Main Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              const SizedBox(height: 20),
                              // Dynamic content based on selected tab
                              _getContentForSelectedTab(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Sidebar (Right side as requested)
             Directionality(
      textDirection: TextDirection.ltr,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(-3, 0),
                      ),
                    ],
                  ),
                  child: Directionality(
                      textDirection: TextDirection.rtl,
                    child: ListView(
                      
                      padding: const EdgeInsets.all(15),
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'القائمة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SidebarButton(
                          text: 'إضافة منتج جديد',
                          icon: Icons.add_box,
                          isSelected: _selectedTab == 'add_product',
                          onPressed: () => _onTabSelected('add_product'),
                        ),
                        SidebarButton(
                          text: 'جميع المنتجات',
                          icon: Icons.list_alt,
                          isSelected: _selectedTab == 'all_products',
                          onPressed: () => _onTabSelected('all_products'),
                        ),
                        SidebarButton(
                          text: 'إضافة قسم جديد',
                          icon: Icons.category,
                          isSelected: _selectedTab == 'add_category',
                          onPressed: () => _onTabSelected('add_category'),
                        ),
                        SidebarButton(
                          text: 'جميع الأقسام',
                          icon: Icons.view_list,
                          isSelected: _selectedTab == 'all_categories',
                          onPressed: () => _onTabSelected('all_categories'),
                        ),
                        SidebarButton(
                          text: 'طلبات بانتظار الموافقة',
                          icon: Icons.hourglass_empty,
                          isSelected: _selectedTab == 'orders_waiting',
                          onPressed: () => _onTabSelected('orders_waiting'),
                        ),
                        SidebarButton(
                          text: 'طلبات تمت الموافقة عليها',
                          icon: Icons.check_circle,
                          isSelected: _selectedTab == 'orders_approved',
                          onPressed: () => _onTabSelected('orders_approved'),
                        ),
                        SidebarButton(
                          text: 'طلبات تم توصيلها',
                          icon: Icons.local_shipping,
                          isSelected: _selectedTab == 'orders_delivered',
                          onPressed: () => _onTabSelected('orders_delivered'),
                        ),
                        SidebarButton(
                          text: 'طلبات تم رفضها',
                          icon: Icons.cancel,
                          isSelected: _selectedTab == 'orders_refused',
                          onPressed: () => _onTabSelected('orders_refused'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SidebarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const SidebarButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Colors.lightBlue;
    final Color unselectedColor = Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    selectedColor.withOpacity(0.15),
                    selectedColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? selectedColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.12),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            hoverColor: selectedColor.withOpacity(0.07),
            splashColor: selectedColor.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? selectedColor : unselectedColor.withOpacity(0.7),
                    size: 24,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 17,
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 6,
                      height: 32,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}