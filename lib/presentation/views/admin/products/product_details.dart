import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/bloc/cart/cart_cubit.dart';
import 'package:shop_app/presentation/bloc/cart/cart_states.dart';
import 'package:shop_app/presentation/const/app_message.dart';
import 'package:shop_app/presentation/resources/color_manager.dart';
import 'package:shop_app/presentation/views/admin/admin_view.dart';
import 'edit_product.dart';

class AdminProductDetails extends StatelessWidget {
  final DocumentSnapshot posts;
  final String tag;

  const AdminProductDetails({
    Key? key,
    required this.posts,
    required this.tag,
  }) : super(key: key);

  Future<void> _showDeleteConfirmation(BuildContext context, CartCubit cubit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل أنت متأكد أنك تريد حذف هذا المنتج؟'),
                Text('لا يمكن التراجع عن هذا الإجراء.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء', style: TextStyle(color: ColorsManager.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                cubit.DeleteDataInFireBase(posts: posts);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CartCubit(),
      child: BlocConsumer<CartCubit, CartStates>(
        listener: (context, state) {
          if (state is DeleteProductsSuccessState) {
            appMessage(text: 'تم الحذف بنجاح');
            Get.offAll(const AdminView());
          }
        },
        builder: (context, state) {
          CartCubit cubit = CartCubit.get(context);
          
          return Padding(
            padding: const EdgeInsets.only(left:38.0,right: 37,top:9,bottom: 9),
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title:  Text(posts['nameAr'],style:const TextStyle(color:Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold
                ),),
                centerTitle: true,
                backgroundColor: Colors.blue,
                elevation: 2,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,color: Colors.white,),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image with Hero Animation
                    Hero(
                      tag: tag,
                      child: Container(
                        height: 410,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            height:300,
                            posts['image'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Product Details Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Row(
                              
                              children: [
                                Text(
                                  posts['nameAr'],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsManager.primary,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                               const SizedBox(width: 33,),
                                Row(children: [
                                  const Icon(Icons.star,color:Colors.amber,size: 25,),
                                  Text(
                                    posts['rate'].toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsManager.primary,
                                    ),
                                  ),
                                ],)
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            Text(
                              posts['desAr'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.start,
                            ),
                             const SizedBox(height: 16),
                            // Divider
                            const Divider(height: 1, color: Colors.grey),
                            
                            const SizedBox(height: 16),
                            
                            // Price
                            Row(
                              children: [
                                const Text(
                                  'السعر: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "${posts['price']} ر.س",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsManager.primary,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Edit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(EditProduct(posts: posts));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                )),
                                child: const Text(
                                  'تعديل المنتج',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Delete Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showDeleteConfirmation(context, cubit);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'حذف المنتج',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}