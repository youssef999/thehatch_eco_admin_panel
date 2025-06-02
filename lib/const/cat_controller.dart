import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class CatController extends GetxController {
  List<Uint8List> imagesBytes = [];
  List<String> uploadedFileURLs = [];
  bool isImageUploading = false;

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
