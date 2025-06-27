import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shop_app/const/cat_controller.dart';
import 'package:shop_app/const/image_widget.dart';
import '../../../bloc/admin/admin-states.dart';
import '../../../bloc/admin/admin_cubit.dart';
import '../../../const/app_message.dart';
import '../../../resources/color_manager.dart';
import '../../../widgets/custom_textformfield.dart';
import '../admin_view.dart';

class AddNewProduct extends StatelessWidget {
  const AddNewProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    CatController catController = Get.put(CatController());
    final isTablet = MediaQuery.of(context).size.width > 600;

    return BlocProvider(
      create: (context) => AdminCubit()..fetchCat(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AddNewProductSuccessState) {
            appMessage(text: 'تم اضافة المنتج بنجاح');
            Get.offAll(const AdminView());
          }
          if(state is setImageSuccessState){
            print("IMAGE SUCCESS....");
          }
        },
        builder: (context, state) {
          AdminCubit cubit = AdminCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.grey[50],
            // appBar: AppBar(
            //   elevation: 2,
            //   backgroundColor: Colors.white,
            //   title: const Text('إضافة منتج جديد', style: TextStyle(color: Colors.black)),
            //   centerTitle: true,
            // ),
            body: Padding(
              padding: const EdgeInsets.only(top:18.0),
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isTablet ? 700 : double.infinity),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.blue,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left:90.0,right: 90,bottom: 12,top:12),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Images Section
                           // _buildImageGallery(context, cubit),
                             const Column(
                                      children: [
                        SizedBox(height: 24),
                        ImageWidget(txt: ' اضف صور المنتج '),
                        SizedBox(height: 20),
                                      ],
                                    ),
                            const SizedBox(height: 24),
                            // Product Name Fields
                            _buildSectionHeader('اسم المنتج'),
                            _buildDualInputFields(
                              cubit.nameController, "الاسم الانجليزي",
                              cubit.nameArController, "الاسم عربي",
                            ),
                                    
                            const SizedBox(height: 24),
                            // Category Dropdowns
                            _buildSectionHeader('القسم'),
                            _buildDualDropdowns(
                              cubit.selectedValue, cubit.dataList, 'nameAr', cubit.changeCatData,
                              cubit.selectedVal2, cubit.dataList, 'name', cubit.changeCatData2,
                            ),
                                    
                            const SizedBox(height: 24),
                            // Description Fields
                            _buildSectionHeader('وصف المنتج'),
                            _buildDualInputFields(
                              cubit.desController, "وصف المنتج",
                              cubit.desArController, "وصف المنتج بالعربية",
                              maxLines: 3,
                            ),
                                    
                            const SizedBox(height: 24),
                            // Pricing Fields
                            _buildSectionHeader('السعر والكمية'),
                            _buildTripleInputFields(
                              cubit.oldController, "سعر قبل الخصم",
                              cubit.price, "سعر المنتج",
                              cubit.quantController, "الكمية",
                            ),
                                    
                            const SizedBox(height: 32),
                            // Add Button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                              label: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  cubit.wait ? 'قيد التحميل...' : "إضافة المنتج",
                                  style: const TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                              onPressed: cubit.wait ? null : () => cubit.addDataToFireBase(
                                catController.uploadedFileURLs
                              ),
                            ),
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

  // Helper widgets for modularity and clarity
Widget _buildImageGallery(BuildContext context, AdminCubit cubit) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'صور المنتج',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cubit.selectedImages.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            if (index == cubit.selectedImages.length) {
              // Add image button
              return GestureDetector(
                onTap: cubit.pickImages,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorsManager.primary, width: 2),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 36, color: ColorsManager.primary),
                ),
              );
            }
            // Display selected image
            final image = cubit.selectedImages[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(image.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => cubit.removeImage(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      // Show image paths for debugging
      if (cubit.selectedImages.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cubit.selectedImages
              .map((img) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      img.path,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
        ),
    ],
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorsManager.primary)),
    );
  }

  Widget _buildDualInputFields(
    TextEditingController controller1, String hint1,
    TextEditingController controller2, String hint2, {int maxLines = 1}
  ) {
    return Row(
      children: [
        Expanded(child:
        CustomTextFormField(controller: controller1, hint: hint1, max: maxLines,
        
        obx: false, ontap: (){}, type:TextInputType.text, obs: false, color: Colors.black,
        )
        ),

        const SizedBox(width: 12),

        Expanded(child: CustomTextFormField(controller: controller2, hint: hint2, max: maxLines,
          obx: false, ontap: (){}, type:TextInputType.text, obs: false, color: Colors.black,
        )),
      ],
    );
  }

  Widget _buildDualDropdowns(
    String? value1, List dataList, String key1, Function(String) onChanged1,
    String? value2, List dataList2, String key2, Function(String) onChanged2
  ) {
    // Implement two dropdowns side by side
    return Row(
      children: [
        Expanded(child: _customDropdown(value1, dataList, key1, onChanged1)),
        const SizedBox(width: 12),
        Expanded(child: _customDropdown(value2, dataList2, key2, onChanged2)),
      ],
    );
  }

  Widget _customDropdown(
    String? value, List dataList, String key, Function(String) onChanged
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: dataList.map<DropdownMenuItem<String>>((data) {
        return DropdownMenuItem<String>(
          value: data[key].toString(),
          child: Text(data[key]),
        );
      }).toList(),
      onChanged: (val) => onChanged(val!),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTripleInputFields(
    TextEditingController controller1, String hint1,
    TextEditingController controller2, String hint2,
    TextEditingController controller3, String hint3,
  ) {
    return Row(
      children: [
        Expanded(child: CustomTextFormField(controller: controller1, hint: hint1, type: TextInputType.number,
        obx: false, ontap: (){}, obs: false, color: Colors.black
        )),
        const SizedBox(width: 12),
        Expanded(child: CustomTextFormField(controller: controller2, hint: hint2, type: TextInputType.number,
        obx: false, ontap: (){}, obs: false, color: Colors.black)
        ),
        const SizedBox(width: 12),
        Expanded(child: CustomTextFormField(controller: controller3, hint: hint3, 
        type: TextInputType.number, obx: false, ontap: (){}, obs: false, color: Colors.black)),
      ],
    );
  }
}
