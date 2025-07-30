import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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

class AddNewProduct extends StatefulWidget {
  const AddNewProduct({Key? key}) : super(key: key);

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoSignIn(context);
    });
  }

  Future<void> autoSignIn(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    const String email = 'test@gmail.com';
    const String password = '123456';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لم يتم العثور على حساب بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-disabled':
          errorMessage = 'تم تعطيل هذا الحساب';
          break;
        default:
          errorMessage = 'حدث خطأ: ${e.message}';
      }
      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Navigator.pop(context);
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CatController catController = Get.put(CatController());
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Theme(
      data: ThemeData(
        primaryColor: ColorsManager.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorsManager.primary,
          primary: ColorsManager.primary,
          secondary: Colors.blueAccent,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: BlocProvider(
        create: (context) => AdminCubit()..fetchCat(),
        child: BlocConsumer<AdminCubit, AdminStates>(
          listener: (context, state) {
            if (state is AddNewProductSuccessState) {
              appMessage(text: 'تم إضافة المنتج بنجاح');
              Get.offAll(const AdminView());
            }
            if (state is setImageSuccessState) {
              print("IMAGE SUCCESS....");
            }
          },
          builder: (context, state) {
            final AdminCubit cubit = AdminCubit.get(context);

            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: const Text(
                  'إضافة منتج جديد',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Get.back(),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Widget (Unchanged)
                          const Column(
                            children: [
                              ImageWidget(title: 'اضف صور المنتج'),
                              SizedBox(height: 20),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Product Name Section
                          _buildSectionHeader(context, 'اسم المنتج'),
                          _buildDualInputFields(
                            controller1: cubit.nameController,
                            hint1: 'الاسم بالإنجليزية',
                            controller2: cubit.nameArController,
                            hint2: 'الاسم بالعربية',
                          ),
                          const SizedBox(height: 24),

                          // Category Section
                          _buildSectionHeader(context, 'القسم'),
                          _buildDualDropdowns(
                            value1: cubit.selectedValue,
                            dataList1: cubit.dataList,
                            key1: 'nameAr',
                            onChanged1: cubit.changeCatData,
                            value2: cubit.selectedVal2,
                            dataList2: cubit.dataList,
                            key2: 'name',
                            onChanged2: cubit.changeCatData2,
                          ),
                          const SizedBox(height: 24),

                          // Description Section
                          _buildSectionHeader(context, 'وصف المنتج'),
                          _buildDualInputFields(
                            controller1: cubit.desController,
                            hint1: 'وصف المنتج بالإنجليزية',
                            controller2: cubit.desArController,
                            hint2: 'وصف المنتج بالعربية',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // Pricing Section
                          _buildSectionHeader(context, 'السعر والكمية'),
                          _buildTripleInputFields(
                            controller1: cubit.oldController,
                            hint1: 'سعر قبل الخصم',
                            controller2: cubit.price,
                            hint2: 'سعر المنتج',
                            controller3: cubit.quantController,
                            hint3: 'الكمية',
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: cubit.wait
                                  ? null
                                  : () {
                                      if (_validateForm(cubit)) {
                                        cubit.addDataToFireBase(catController.uploadedFileURLs);
                                      } else {
                                        Get.snackbar(
                                          'خطأ',
                                          'يرجى ملء جميع الحقول المطلوبة',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.add, size: 24),
                              label: Text(
                                cubit.wait ? 'جارٍ التحميل...' : 'إضافة المنتج',
                                style: const TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
      ),
    );
  }

  // Form Validation
  bool _validateForm(AdminCubit cubit) {
    return cubit.nameController.text.isNotEmpty &&
        cubit.nameArController.text.isNotEmpty &&
        cubit.desController.text.isNotEmpty &&
        cubit.desArController.text.isNotEmpty &&
        cubit.oldController.text.isNotEmpty &&
        cubit.price.text.isNotEmpty &&
        cubit.quantController.text.isNotEmpty &&
        cubit.selectedValue != null &&
        cubit.selectedVal2 != null;
  }

  // Section Header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
        semanticsLabel: title,
      ),
    );
  }

  // Dual Input Fields
  Widget _buildDualInputFields({
    required TextEditingController controller1,
    required String hint1,
    required TextEditingController controller2,
    required String hint2,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: controller1,
            hint: hint1,
            max: maxLines,
            obx: false,
            ontap: () {},
            type: TextInputType.text,
            obs: false,
            color: Colors.black,
         //   validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
            controller: controller2,
            hint: hint2,
            max: maxLines,
            obx: false,
            ontap: () {},
            type: TextInputType.text,
            obs: false,
            color: Colors.black,
          //  validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
      ],
    );
  }

  // Dual Dropdowns
  Widget _buildDualDropdowns({
    required String? value1,
    required List dataList1,
    required String key1,
    required Function(String) onChanged1,
    required String? value2,
    required List dataList2,
    required String key2,
    required Function(String) onChanged2,
  }) {
    return Row(
      children: [
        Expanded(child: _customDropdown(value1, dataList1, key1, onChanged1)),
        const SizedBox(width: 16),
        Expanded(child: _customDropdown(value2, dataList2, key2, onChanged2)),
      ],
    );
  }

  Widget _customDropdown(
    String? value,
    List dataList,
    String key,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: dataList.map<DropdownMenuItem<String>>((data) {
        return DropdownMenuItem<String>(
          value: data[key].toString(),
          child: Text(data[key], style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
      onChanged: (val) => onChanged(val!),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: 'اختر القسم',
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (value) => value == null ? 'يرجى اختيار قسم' : null,
    );
  }

  // Triple Input Fields
  Widget _buildTripleInputFields({
    required TextEditingController controller1,
    required String hint1,
    required TextEditingController controller2,
    required String hint2,
    required TextEditingController controller3,
    required String hint3,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: controller1,
            hint: hint1,
            type: TextInputType.number,
            obx: false,
            ontap: () {},
            obs: false,
            color: Colors.black,
            //validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
            controller: controller2,
            hint: hint2,
            type: TextInputType.number,
            obx: false,
            ontap: () {},
            obs: false,
            color: Colors.black,
           // validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
            controller: controller3,
            hint: hint3,
            type: TextInputType.number,
            obx: false,
            ontap: () {},
            obs: false,
            color: Colors.black,
          //  validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
        ),
      ],
    );
  }
}