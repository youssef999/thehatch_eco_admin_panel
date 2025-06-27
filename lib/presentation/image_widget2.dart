



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/cat_controller.dart';

class ImageWidget2 extends StatelessWidget {
  final String txt;
  const ImageWidget2({super.key, required this.txt});

  @override
  Widget build(BuildContext context) {
    final CatController controller = Get.put(CatController());

    return GetBuilder<CatController>(
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                txt,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),

              // Select Images Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text(" اختر الصور  "),
                onPressed: () async {
                  await controller.pickMultipleImages();
                },
              ),
              const SizedBox(height: 18),

              // Images Grid or Empty State
              controller.imagesBytes.isEmpty
                  ? Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(" اختر الصور ", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              )
                  : Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Image.memory(
              controller.imagesBytes[0],
              fit: BoxFit.contain,
               width: double.infinity-22,
              height: 122,
            ),
          ),
        ),



              // SizedBox(
              //   height: 430,
              //   child: GridView.builder(
              //     shrinkWrap: true,
              //     physics: const NeverScrollableScrollPhysics(),
              //     itemCount: controller.imagesBytes.length,
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 1,
              //       mainAxisSpacing: 5,
              //       crossAxisSpacing: 5,
              //       childAspectRatio: 0.96,
              //     ),
              //     itemBuilder: (context, index) {
              //
              //     },
              //   ),
              // ),
              const SizedBox(height: 18),

              // Uploading Indicator
              if (controller.isImageUploading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),
                ),

              // Uploaded URLs
              if (!controller.isImageUploading && controller.uploadedFileURLs.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   "Uploaded URLs:",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.deepPurple,
                      //   ),
                      // ),
                      // const SizedBox(height: 6),
                      // SizedBox(
                      //   height: 60,
                      //   child: SingleChildScrollView(
                      //     child: Text(
                      //       controller.uploadedFileURLs.join('\n'),
                      //       style: const TextStyle(fontSize: 11, color: Colors.black87),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}