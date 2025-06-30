
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CatController extends GetxController {
  List<Uint8List> imagesBytes = [];
  List<String> uploadedFileURLs = [];
  bool isImageUploading = false;

  List<String> uploadedImages = [];
  bool uploading = false;

  // Future<void> handleUpload(List<String>urlsData) async {
  // //  setState(() => uploading = true);
  //   final urls = await uploadImagesToImgbb();
  // //  setState(() {
  //     uploadedImages = urls;
  //     uploading = false;
  //  // });
  //   //if (urls.isNotEmpty) saveToFirestore();
  // }

  // Future<List<String>> uploadImagesToImgbb() async {
  //   final List<String> imageUrls = [];
  //   final input = html.FileUploadInputElement();
  //   input.accept = 'image/*';
  //   input.multiple = true;
  //   input.click();
  //   await input.onChange.first;
  //
  //   final files = input.files;
  //   if (files != null) {
  //     for (var file in files) {
  //       final reader = html.FileReader();
  //       reader.readAsDataUrl(file);
  //       await reader.onLoad.first;
  //
  //       final encoded = reader.result.toString().split(',').last;
  //
  //       final response = await http.post(
  //         Uri.parse("https://api.imgbb.com/1/upload?key=d2ddffc93cc2910f78901f7d0aedfed0"),
  //         body: {"image": encoded},
  //       );
  //
  //       final data = jsonDecode(response.body);
  //       imageUrls.add(data['data']['url']);
  //     }
  //   }
  //   return imageUrls;
  // }
  // Pick multiple images using file_picker
  Future<void> pickMultipleImages() async {
    imagesBytes.clear();
    uploadedFileURLs.clear();
    isImageUploading = false;
    update();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.bytes != null) {
          imagesBytes.add(file.bytes!);
        }
      }
      update(); // Show previews immediately

      // Optionally, upload immediately after picking:
      isImageUploading = true;
      update();
      for (var image in imagesBytes) {
        String url = await uploadImage(image);
        uploadedFileURLs.add(url);
      }
      isImageUploading = false;
      update();
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(Uint8List imageData) async {
    Reference ref = FirebaseStorage.instance.ref().child('Folder');
    String id = const Uuid().v1();
    ref = ref.child(id);

    UploadTask uploadTask = ref.putData(
      imageData,
      SettableMetadata(contentType: 'image/png'),
    );
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
