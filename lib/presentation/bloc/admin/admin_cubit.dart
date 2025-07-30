// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/presentation/widgets/Custom_Text.dart';
import '../../const/app_message.dart';
import '../../views/admin/admin_view.dart';
import 'admin-states.dart';


 class AdminCubit extends Cubit<AdminStates> {

  AdminCubit() : super(AppIntialState());
  static AdminCubit get(context) => BlocProvider.of(context);
  TextEditingController nameController = TextEditingController();
    TextEditingController nameArController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController coinsController = TextEditingController();
  TextEditingController codeIdController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController freeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController numController = TextEditingController();
  TextEditingController desController = TextEditingController();

    TextEditingController desArController = TextEditingController();


  TextEditingController ruleontroller = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController priceVal = TextEditingController();
  TextEditingController quant = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController video = TextEditingController();
  TextEditingController days = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController catController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
 
  XFile? pickedImageXFile;
  var imageLink = '';
  String downloadUrl = '';
  List<String> downloadUrls = [];
  bool data=false;
  List<XFile>? pickedImageXFiles;
  bool isImage=false;

  String selectedValue='اكسسوارات';
  String selectedValue2='الكويت';
  List dataList = [];
  List dataList2 = [];
  bool wait=false;


    final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      selectedImages = images;
      emit(AdminImagesUpdated()); // Use your own state class
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    emit(AdminImagesUpdated());
  }

  showDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            title: const Custom_Text(
              text: 'الصورة ',
              alignment: Alignment.center,
              fontSize: 19,
              color: Colors.black,
            ),
            children: [
              SimpleDialogOption(
                child: const Custom_Text(
                  text: 'كاميرا ',
                  alignment: Alignment.center,
                  fontSize: 14,
                  color: Colors.black,
                ),
                onPressed: () {
                  captureImage();
                },
              ),
              SimpleDialogOption(
                  child: const Custom_Text(
                    text: ' اختر صورة  ',
                    alignment: Alignment.center,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    pickImage();
                  }),
              SimpleDialogOption(
                  child: const Custom_Text(
                    text: 'الغاء  ',
                    alignment: Alignment.center,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    Get.back();
                  })
            ],
          );
        });
  }

  captureImage() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.camera);
    Get.back();
    pickedImageXFile;
    emit(setImageSuccessState());
    changeData();
    // uploadImageToFirebaseStorage(pickedImageXFile!);
  }

  pickImage() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.gallery);
    Get.back();
    emit(setImageSuccessState());
    changeData();
    //   uploadImageToFirebaseStorage(pickedImageXFile!);
  }

String selectedVal2='Accessories';

changeCatData2(String val){
    selectedVal2=val;
    emit(ChangeCatSuccessState());
  }


  changeCatData(String val){
    selectedValue=val;
    emit(ChangeCatSuccessState());
  }

  changeCountryData(String val){
    selectedValue2=val;
    emit(ChangeCountrySuccessState());
  }

  Future<String> uploadImageToFirebaseStorage(XFile image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle any errors that occur during the upload process
      return '';
    }
  }




  Future uploadMultiImageToFirebaseStorage(List<XFile> images) async {


    for(int i=0;i<images.length;i++){

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference =
        FirebaseStorage.instance.ref().child('images/$fileName');
        UploadTask uploadTask = reference.putFile(File(images[i].path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

      } catch (e) {
        // Handle any errors that occur during the upload process
        print('Error uploading image to Firebase Storage: $e');

      }
    }

    return downloadUrls;
  }



  addCountryToFireBase() async {
    uploadImageToFirebaseStorage(pickedImageXFile!).then((value) async {
      if(nameController.text.length>1){
        await FirebaseFirestore.instance.collection('countries').add({
          'name': nameController.text,
          'currency': currencyController.text,
          'img': downloadUrl,
        }).then((value) {
         appMessage(text: 'تم اضافة البلد بنجاح');
         Get.off(const AdminView());
        });

      }else{
        appMessage(text: 'تاكد من ادخال البيانات بشكل صحيح');
      }
    });
  }

  changeCatFirst(String val){

    selectedValue=val;
    emit(ChangeCatFirstSuccessState());
  }
  changeCountryFirst(String val){

    selectedValue2=val;
    emit(ChangeCountrySuccessState());
  }


  Future<void> fetchCat() async {
    try {

      FirebaseAuth.instance.signInWithEmailAndPassword
        (email: 'test@gmail.com', password: '1234567').then((v){
          print("DONE......");
      });
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('cat').get();
   //   setState(() {
        dataList = querySnapshot.docs.map((doc) => doc.data()).toList();
        print("DATA===$dataList");
        emit(GetCatSuccessState());
    //  });
    } catch (e) {
      print('Error retrieving data: $e');
    }
  }

  Future<void> fetchCountries() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('countries').get();
      //   setState(() {
      dataList2 = querySnapshot.docs.map((doc) => doc.data()).toList();
      emit(GetCountrySuccessState());
      //  });
    } catch (e) {
      print('Error retrieving data: $e');
    }
  }

  // Future<List> getDataFromCollection(String collectionName) async {
  //   List dataList = [];
  //
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
  //     for (var doc in querySnapshot.docs) {
  //       dataList.add(doc.data());
  //     }
  //   } catch (e) {
  //     print('Error retrieving data: $e');
  //   }
  //
  //   print(dataList);
  //   return dataList;
  // }

  pickMultiImage() async {
    pickedImageXFiles = await _picker.pickMultiImage(
      imageQuality: 100,
    );
    isImage = true;

    emit(setImageSuccessState());
  }

 TextEditingController quantController=TextEditingController();
 TextEditingController oldController=TextEditingController();

  addDataToFireBase(List<String>images) async {
    wait=true;
    emit(ChangeWaitSuccessState());

      // if(pickedImageXFiles==null){
      //   appMessage(text: 'اختر الصورة');
      // }
     // uploadMultiImageToFirebaseStorage(pickedImageXFiles!).then((value) async {

      final random = Random.secure();
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGRTYUIOAPMSKSOAPALIOWWNCVZ';
      String result = '';


      for (int i = 0; i < 16; i++) {
        result += chars[random.nextInt(chars.length)];
      }

      if(nameController.text.length>1&&desController.text.isNotEmpty&&price.text.isNotEmpty){
        await FirebaseFirestore.instance.collection('products').add({
          'name': nameController.text,
          'nameAr':nameArController.text,
          'des': desController.text,
          'desAr':desArController.text,
          'image': images[0],
          'images':images,
          'productid': result,
          'brand':'',
          'rate':0,
          'quant':num.parse(quantController.text),
          'date':DateTime.now().toString(),
          'oldPrice':num.parse(oldController.text),
          'price': num.parse(price.text),
          'cat': selectedValue,
          'catAr':selectedVal2,
        }).then((value) {
          print('addddddddd');
          emit(AddNewProductSuccessState());
          wait=false;
          emit(ChangeWaitSuccessState2());
        });
      }else{
        appMessage(text: 'تاكد من ادخال البيانات بشكل صحيح');
      }
      downloadUrls=[];
   // });

  }

  splashToFireBase() async {
    uploadMultiImageToFirebaseStorage(pickedImageXFiles!).then((value) async {
      await FirebaseFirestore.instance.collection('splash').add({
        'image': downloadUrl,
      }).then((value) {
        print('addddddddd');
        emit(AddNewSplashSuccessState());
      });

    });

  }
 adminLogin()async{

      final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth
            .signInWithEmailAndPassword(
            email: 'test@gmail.com', password:'123456');

 }
  addCatToFireBase(List<String>images) async {

    adminLogin();
     // if(pickedImageXFiles==null){
     //    appMessage(text: 'اختر الصورة');
     //  }
      //uploadMultiImageToFirebaseStorage(pickedImageXFiles!).then((value) async {

       print(downloadUrls.toString());
       print("////");
        if(nameController.text.length>1 && nameArController.text.length>1&&images.isNotEmpty
    ){

          //print("dd=="+downloadUrls[0]);
      await FirebaseFirestore.instance.collection('cat').add({
        'name': nameController.text,
        'nameAr':nameController.text,
        'image': images[0]
      }).then((value) {
        print('addddddddd');
        emit(AddNewCatSuccessState());
      });
    }else{
      appMessage(text: 'تاكد من ادخال البيانات بشكل صحيح');
    }
    downloadUrls=[];
    //  });
   
  }

  changeData(){
    data=true;
    emit(ChangeDataSuccessState());
  }


  EditDataInFireBase ({required DocumentSnapshot posts,required List<String>images })async{

    String name='';
    String nameAr='';
    num pr=0.0;
    //num quantity=0.0;
    String des='';
    String desEn='';

    if(nameArController.text.length<2){
      nameAr=posts['nameAr'];
    }
    else{
      nameAr=nameArController.text;
    }



    if(nameController.text.length<2){
      name=posts['name'];
    }
    else{
      name=nameController.text;
    }

    if(desArController.text.length<2){
      des=posts['desAr'];
    }
    else{
      des=desArController.text;
    }

    if(desController.text.length<2){
      desEn=posts['des'];
    }
    else{
      desEn=desController.text;
    }


    // if(priceVal.text.isEmpty){
    //   val=posts['val'];
    // }
    // else{
    //   val=priceVal.text;
    // }


    if(price.text.length<2){
      pr=posts['price'];
    }else{
      pr=num.parse(price.text);
    }





    if(images.isNotEmpty){
    final CollectionReference _updates =
    FirebaseFirestore.instance.collection('products');
    await _updates
        .where('productid', isEqualTo: posts['productid'])
        .get().then((snapshot) {
      snapshot.docs.last.reference.update({
        'name':name,
        'price': pr,
        'nameAr':nameAr,
        'cat': selectedValue,
        'images':images,
        'image':images[0],
        //'value':val,
        'des':desEn,
        'desAr':des,
      }).then((value) {
        print("EDITED");
        emit(EditProductsSuccessState());
      });
    });
  }else{


      final CollectionReference _updates =
      FirebaseFirestore.instance.collection('products');
      await _updates
          .where('productid', isEqualTo: posts['productid'])
          .get().then((snapshot) {
        snapshot.docs.last.reference.update({
          'name':name,
          'price': pr,
          'nameAr':nameAr,
          'cat': selectedValue,
          //'value':val,
          'des':desEn,
          'desAr':des,
        }).then((value) {
          print("EDITED");
          emit(EditProductsSuccessState());
        });
      });


    }
  }


  EditDataInFireBase2 ({required DocumentSnapshot posts})async{

    String name='';


    if(nameController.text.length<2){
      name=posts['txt'];
    }
    else{
      name=nameController.text;
    }


    final CollectionReference _updates =
    FirebaseFirestore.instance.collection('txt');
    await _updates
        .where('id', isEqualTo: '1')
        .get().then((snapshot) {
      snapshot.docs.last.reference.update({
        'txt':name,

      }).then((value) {
        print("EDITED");
        emit(EditProductsSuccessState());
      });
    });
  }

  DeleteDataInFireBase ({required DocumentSnapshot posts})async{

    final CollectionReference _updates =
    FirebaseFirestore.instance.collection('products');
    await _updates
        .where('productid', isEqualTo: posts['productid'])
        .get().then((snapshot) {
      snapshot.docs.last.reference.delete()
    .then((value) {
        print("DELETED");
        emit(DeleteProductsSuccessState());
      });
    });
  }


  DeleteCountryInFireBase ({required DocumentSnapshot posts})async{

    final CollectionReference _updates =
    FirebaseFirestore.instance.collection('countries');
    await _updates
        .where('name', isEqualTo: posts['name'])
        .get().then((snapshot) {
      snapshot.docs.last.reference.delete()
          .then((value) {
        print("DELETED");
        emit(DeleteProductsSuccessState());
      });
    });
  }



}
