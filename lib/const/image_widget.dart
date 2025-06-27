import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_app/const/cat_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageWidget extends StatelessWidget {
  final String title;
  const ImageWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final CatController controller = Get.put(CatController());

    return GetBuilder<CatController>(
      builder: (_) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title with improved typography
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple[800],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Responsive image grid section
                _buildImageSection(context, controller),
                const SizedBox(height: 24),

                // Upload status indicators
                _buildUploadStatus(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(BuildContext context, CatController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Web-optimized select button
        SizedBox(
          width: 300,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
            ),
            icon: const Icon(Icons.cloud_upload, size: 24),
            label: const Text("اختر الصور", style: TextStyle(fontSize: 18)),
            onPressed: () async => await controller.pickMultipleImages(),
          ),
        ),
        const SizedBox(height: 28),

        // Responsive image grid
        if (controller.imagesBytes.isEmpty) ...[
          _buildEmptyState()
        ] else ...[
          _buildImageGrid(controller)
        ]
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 64,
                color: Colors.grey),
            SizedBox(height: 16),
            Text("لم يتم اختيار صور بعد",
                style: TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(CatController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 600
            ? 3
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.imagesBytes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.memory(
                    controller.imagesBytes[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                   //     onTap: () => controller.removeImage(index),
                        child: Icon(Icons.close,
                            size: 20,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadStatus(CatController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isImageUploading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  strokeWidth: 2.5,
                ),
                const SizedBox(width: 16),
                Text("جاري رفع الصور...",
                    style: TextStyle(
                        color: Colors.deepPurple[700],
                        fontSize: 16)),
              ],
            ),
          ),

        if (!controller.isImageUploading && controller.uploadedFileURLs.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("الروابط المرفوعة:",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple[800],
                        fontSize: 17)),
                const SizedBox(height: 10),
                ...controller.uploadedFileURLs.map((url) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
      ],
    );
  }
}

