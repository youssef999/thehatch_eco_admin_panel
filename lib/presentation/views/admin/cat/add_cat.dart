import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';
import '../../../../const/cat_controller.dart';
import '../../../../const/image_widget.dart';
import '../../../bloc/admin/admin-states.dart';
import '../../../bloc/admin/admin_cubit.dart';
import '../../../const/app_message.dart';
import '../../../resources/color_manager.dart';
import '../../../widgets/Custom_button.dart';
import '../../../widgets/custom_textformfield.dart';
import '../admin_view.dart';

class AddNewCat extends StatelessWidget {
  const AddNewCat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CatController catController = Get.put(CatController());

    return BlocProvider(
      create: (_) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AddNewCatSuccessState) {
            appMessage(text: 'تم اضافة القسم بنجاح');
            Get.offAll(const AdminView());
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          final isImagesSelected =
              cubit.pickedImageXFiles != null && cubit.pickedImageXFiles!.isNotEmpty;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 5,
              backgroundColor: ColorsManager.primary,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Logo
                  // Container(
                  //   height: 100,
                  //   width: 200,
                  //   margin: const EdgeInsets.only(bottom: 30),
                  //   child: Image.asset('assets/images/logo.png'),
                  // ),

                  // Image Section Title
           const ImageWidget( title:'اضف صورة القسم'),


                  //const SizedBox(height: 16),

                  // // Image Picker and Preview
                  // isImagesSelected
                  //     ? Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //       height: 110,
                  //       child: ListView.separated(
                  //         scrollDirection: Axis.horizontal,
                  //         itemCount: cubit.pickedImageXFiles!.length,
                  //         separatorBuilder: (_, __) => const SizedBox(width: 10),
                  //         itemBuilder: (context, index) {
                  //           return ClipRRect(
                  //             borderRadius: BorderRadius.circular(15),
                  //             child: Image.file(
                  //               File(cubit.pickedImageXFiles![index].path),
                  //               height: 180,
                  //               width: 180,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //     //const SizedBox(height: 20),
                  //     // ElevatedButton.icon(
                  //     //   onPressed: cubit.pickMultiImage,
                  //     //   icon: const Icon(Icons.add_a_photo_rounded),
                  //     //   label: const Text("إضافة صور أخرى"),
                  //     //   style: ElevatedButton.styleFrom(
                  //     //     backgroundColor: ColorsManager.primary,
                  //     //     foregroundColor: Colors.white,
                  //     //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  //     //     shape: RoundedRectangleBorder(
                  //     //       borderRadius: BorderRadius.circular(12),
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ],
                  // )
                  //     : InkWell(
                  //   onTap: cubit.pickMultiImage,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(vertical: 40),
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: Colors.grey.shade300),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey.withOpacity(0.1),
                  //           blurRadius: 10,
                  //           offset: const Offset(0, 4),
                  //         )
                  //       ],
                  //     ),
                  //     child: const Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                  //         SizedBox(height: 10),
                  //         Custom_Text(
                  //           text: 'اضغط لإضافة الصور',
                  //           color: Colors.black54,
                  //           fontSize: 18,
                  //           alignment: Alignment.center,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 30),

                  // English Name Field
                  CustomTextFormField(
                    controller: cubit.nameController,
                    hint: "اسم القسم باللغة الإنجليزية",
                    color: Colors.black,
                    max: 2,
                    obs: false,
                    obx: false,
                    ontap: () {},
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  // Arabic Name Field
                  CustomTextFormField(
                    controller: cubit.nameArController,
                    hint: "اسم القسم باللغة العربية",
                    color: Colors.black,
                    max: 2,
                    obs: false,
                    obx: false,
                    ontap: () {},
                    type: TextInputType.text,
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "إضافة القسم",
                      onPressed: () {
                        cubit.addCatToFireBase(catController.uploadedFileURLs);
                      },
                      color1: ColorsManager.primary,
                      color2: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
