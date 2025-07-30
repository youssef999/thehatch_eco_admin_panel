import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../const/cat_controller.dart';
import '../../../../const/image_widget.dart';
import '../../../bloc/admin/admin-states.dart';
import '../../../bloc/admin/admin_cubit.dart';
import '../../../const/app_message.dart';
import '../../../resources/color_manager.dart';
import '../admin_view.dart';

class EditProduct extends StatelessWidget {
  final DocumentSnapshot posts;

  EditProduct({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    CatController catController = Get.put(CatController());

    return BlocProvider(
      create: (context) => AdminCubit()
        ..fetchCountries()
        ..fetchCat()
        ..changeCatFirst(posts['cat']),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is EditProductsSuccessState) {
            appMessage(text: 'تم التعديل بنجاح');
            Get.offAll(const AdminView());
          }
        },
        builder: (context, state) {
          AdminCubit cubit = AdminCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorsManager.primary,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              title: const Text(
                'تعديل المنتج',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              elevation: 2,
            ),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1340),
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 11),
                            Image.network(
                              posts['image'],
                            //  width: 110,
                              height: 220,
                              fit: BoxFit.contain,
                            ),


                            const Column(
                              children: [
                                SizedBox(height: 16),
                                ImageWidget(title: ' لتعديل الصور اضغط هنا  '),
                                SizedBox(height: 15),
                              ],
                            ),
                            // Product Image Section
                            // Center(
                            //   child: InkWell(
                            //     onTap: () => cubit.showDialogBox(context),
                            //     child: ClipRRect(
                            //       borderRadius: BorderRadius.circular(12),
                            //       child: cubit.pickedImageXFile != null
                            //           ? Image.file(
                            //         File(cubit.pickedImageXFile!.path),
                            //         width: 280,
                            //         height: 220,
                            //         fit: BoxFit.cover,
                            //       )
                            //           : Image.network(
                            //         posts['image'],
                            //         width: 280,
                            //         height: 220,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //   ),
                            // ),







                            const SizedBox(height: 32),

                            // Product Name (Arabic)
                            _SectionTitle('الاسم'),
                            _LabeledTextField(
                              controller: cubit.nameArController,
                              hint: posts['nameAr'],
                            ),

                            // Product Name (English)
                            _SectionTitle('الاسم انجليزي'),
                            _LabeledTextField(
                              controller: cubit.nameController,
                              hint: posts['name'],
                            ),

                            // Category Dropdown
                            _SectionTitle('القسم'),
                            DropdownButtonFormField<String>(
                              value: cubit.selectedValue,
                              items: cubit.dataList.map<DropdownMenuItem<String>>((data) {
                                return DropdownMenuItem<String>(
                                  value: data['name'].toString(),
                                  child: Text(data['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                cubit.changeCatData(value!);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),

                            // Price
                            _SectionTitle('السعر'),
                            _LabeledTextField(
                              controller: cubit.price,
                              hint: posts['price'].toString(),
                              keyboardType: TextInputType.number,
                            ),

                            // Description (Arabic)
                            _SectionTitle('الوصف'),
                            _LabeledTextField(
                              controller: cubit.desArController,
                              hint: posts['desAr'],
                              maxLines: 6,
                            ),

                            // Description (English)
                            _SectionTitle('الوصف En'),
                            _LabeledTextField(
                              controller: cubit.desController,
                              hint: posts['des'],
                              maxLines: 6,
                            ),

                            const SizedBox(height: 36),

                            // Submit Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  "تعديل",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                // state is EditProductsLoadingState
                                //     ? null
                                     () {
                                  cubit.EditDataInFireBase(posts: posts,

                                      images:  catController.uploadedFileURLs,
                                  );
                                },
                              ),
                            ),

                            // if (state is EditProductsLoadingState)
                            //   const Padding(
                            //     padding: EdgeInsets.only(top: 20),
                            //     child: Center(child: CircularProgressIndicator()),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper Widgets for Clean Code

Widget _SectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8, top: 24),
  child: Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    textAlign: TextAlign.right,
  ),
);

Widget _LabeledTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
