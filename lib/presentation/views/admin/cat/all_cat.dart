

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/const/app_message.dart';
import 'package:shop_app/presentation/resources/color_manager.dart';
import 'package:shop_app/presentation/views/admin/admin_view.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';

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

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.33,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot post = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    hoverColor: ColorsManager.primary2.withOpacity(0.08),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      color: ColorsManager.primary2,
                      shadowColor: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post['image'],
                                height: 167,
                                width: double.infinity,
                                fit: BoxFit.contain
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Product name
                            Custom_Text(
                              text: post['name'],
                              fontSize: 18,
                              alignment: Alignment.center,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),

                            const SizedBox(height: 20),

                            // Delete button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: () {
                                  _showDeleteDialog(context, post['name']);
                                },
                                child: const Text(
                                  'حذف القسم',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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