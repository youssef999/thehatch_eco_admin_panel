
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/presentation/resources/color_manager.dart';
import 'package:shop_app/presentation/views/admin/admin_view.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_obs.dart';


 void main()async {

  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey:"AIzaSyCpQfDQzEzC4h58GAspD1fPsev7UsaIA_g",
          appId: "1:431950103039:web:3a2520ec550b0f355b67ca",
          messagingSenderId:"431950103039",
          storageBucket:  "businessapp-f0d62.appspot.com",
          projectId: "businessapp-f0d62",)
  );
  runApp(const MyApp());
 }


 class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      textDirection:TextDirection.rtl,
      title: 'ADMIN',
      color:ColorsManager.primary,
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme:const AppBarTheme(color:ColorsManager.primary)
      ),
      home:
      const AdminView()
    );
  }
}


