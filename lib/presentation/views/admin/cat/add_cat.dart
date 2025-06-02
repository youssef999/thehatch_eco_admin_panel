import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';
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
    return BlocProvider(
        create: (BuildContext context) => AdminCubit(),
        child: BlocConsumer<AdminCubit, AdminStates>(

            listener: (context, state) {

              if(state is AddNewCatSuccessState){

                appMessage(text: 'تم اضافة القسم بنجاح');

                Get.offAll(const AdminView());

              }
            },

            builder: (context, state) {

              AdminCubit cubit = AdminCubit.get(context);
              return Scaffold(
                backgroundColor:Colors.white,
                appBar:AppBar(
                  elevation: 0,
                  toolbarHeight: 5,
                  backgroundColor:ColorsManager.primary,
                ),
                body:
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Column(
                      children:  [
                        const SizedBox(height: 20,),


                        Container(
                            height: 140,
                            width: 600,
                            color:Colors.white,
                            child: Image.asset('assets/images/logo.png')),




  (cubit.pickedImageXFiles != null
                            && cubit.pickedImageXFiles!.isNotEmpty)?
                        Column(
                          children: [
                            InkWell(
                              child: Container(
                                height:  MediaQuery.of(context).size.width*0.41,
                                width: MediaQuery.of(context).size.width*0.6,
                                decoration:BoxDecoration(
                                    image: DecorationImage(
                                        image:

                                        FileImage(
                                            File(cubit.pickedImageXFiles![0]
                                                .path)),

                                        fit:BoxFit.fill
                                    )
                                ),
                              ),
                              onTap:(){
                                cubit.pickMultiImage();
                              },
                            ),

                            const SizedBox(height: 31,),
                            const Divider(),
                            (cubit.pickedImageXFiles!.length>1)?
                            Container(
                              height:  MediaQuery.of(context).size.width*0.41,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration:BoxDecoration(
                                  image: DecorationImage(
                                      image:FileImage(
                                          File(cubit.pickedImageXFiles![1].path)),
                                      fit:BoxFit.fill
                                  )
                              ),
                            ):const SizedBox(),

                            (cubit.pickedImageXFiles!.length>2)?
                            Container(
                              height:  MediaQuery.of(context).size.width*0.41,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration:BoxDecoration(
                                  image: DecorationImage(
                                      image:FileImage(
                                          File(cubit.pickedImageXFiles![2].path)),
                                      fit:BoxFit.fill
                                  )
                              ),
                            ):const SizedBox(),

                            (cubit.pickedImageXFiles!.length>3)?
                            Container(
                              height:  MediaQuery.of(context).size.width*0.41,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration:BoxDecoration(
                                  image: DecorationImage(
                                      image:FileImage(
                                          File(cubit.pickedImageXFiles![3].path)),
                                      fit:BoxFit.fill
                                  )
                              ),
                            ):const SizedBox(),

                            (cubit.pickedImageXFiles!.length>4)?
                            Container(
                              height:  MediaQuery.of(context).size.width*0.41,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration:BoxDecoration(
                                  image: DecorationImage(
                                      image:FileImage(
                                          File(cubit.pickedImageXFiles![4].path)),
                                      fit:BoxFit.fill
                                  )
                              ),
                            ):const SizedBox(),

                            (cubit.pickedImageXFiles!.length>5)?
                            Container(
                              height:  MediaQuery.of(context).size.width*0.41,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration:BoxDecoration(
                                  image: DecorationImage(
                                      image:FileImage(
                                          File(cubit.pickedImageXFiles![5].path)),
                                      fit:BoxFit.fill
                                  )
                              ),
                            ):const SizedBox(),
                          ],
                        ):  InkWell(
                          child: const Column(
                            children: [

                              CircleAvatar(
                                radius: 100,
                                child:Icon(Icons.image,size: 60,)
                              ),
                              SizedBox(height: 10,),
                              Custom_Text(text: 'اضف صورة ',color:Colors.black,
                                fontSize:21,alignment:Alignment.center,
                              ),
                            ],
                          ),
                          onTap:(){
                            cubit.pickMultiImage();
                          //  cubit.showDialogBox(context);
                          },
                        ),


                        const SizedBox(height: 20,),
                        CustomTextFormField(
                          controller:cubit.nameController,
                          color:Colors.black,
                          hint: "  اسم القسم بالغة الانجليزية  ",
                          max: 2,
                          obs: false,
                          obx: false,
                          ontap:(){},
                          type:TextInputType.text,
                        ),
                          const SizedBox(height: 20,),
                        CustomTextFormField(
                          controller:cubit.nameArController,
                          color:Colors.black,
                          hint: "  اسم القسم بالغة العربية  ",
                          max: 2,
                          obs: false,
                          obx: false,
                          ontap:(){},
                          type:TextInputType.text,
                        ),
                        const SizedBox(height: 20,),

                        CustomButton(text: "اضافة",
                            onPressed: (){

                              cubit. addCatToFireBase();


                            }, color1:ColorsManager.primary,
                            color2: Colors.white),
                        const SizedBox(height: 30,),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}