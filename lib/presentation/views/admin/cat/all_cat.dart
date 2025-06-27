

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/const/app_message.dart';
import 'package:shop_app/presentation/resources/color_manager.dart';
import 'package:shop_app/presentation/views/admin/admin_view.dart';
import 'package:shop_app/presentation/views/admin/products/product_details.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';
import 'package:shop_app/presentation/widgets/Custom_button.dart';

class CatView extends StatelessWidget {
  const CatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: ColorsManager.primary,
        title: const Text(
          "الأقسام",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const CatWidget(),
    );
  }
}

class CatWidget extends StatelessWidget {
  const CatWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cat').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد بيانات حالياً."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.64,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot post = snapshot.data!.docs[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: ColorsManager.primary2,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post['image'],
                          height: 183,
                         // width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Custom_Text(
                        text: post['name'],
                        fontSize: 16,
                        alignment: Alignment.center,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 14),
                      CustomButton(
                        text: 'حذف القسم',
                        onPressed: () {
                          _showDeleteDialog(context, post['name']);
                        },
                        color1: Colors.red.shade700,
                        color2: Colors.red.shade300,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد أنك تريد حذف القسم '$name'؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("حذف"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await DeleteCatByName(name);
            },
          ),
        ],
      ),
    );
  }
}

Future<void> DeleteCatByName(String name) async {
  final CollectionReference categories =
  FirebaseFirestore.instance.collection('cat');

  final query = await categories.where('name', isEqualTo: name).get();

  if (query.docs.isNotEmpty) {
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    appMessage(text: 'تم الحذف بنجاح');
    Get.offAll(const AdminView());
  } else {
    appMessage(text: 'لم يتم العثور على القسم');
  }
}

DeleteCatInFireBase ({required DocumentSnapshot posts})async{

  final CollectionReference _updates =
  FirebaseFirestore.instance.collection('categories');
  await _updates
      .where('name', isEqualTo: posts['name'])
      .get().then((snapshot) {
    snapshot.docs.last.reference.delete()
        .then((value) {
      print("DELETED");
      appMessage(text: 'تم الحذف بنجاح');
      Get.offAll(const AdminView());

    });
  });
}