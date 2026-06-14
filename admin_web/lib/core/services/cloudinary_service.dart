import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Replace these with your Cloudinary credentials or configure them dynamically
  static const String cloudName = 'your_cloud_name';
  static const String uploadPreset = 'awala_presets'; // Unsigned upload preset

  final Dio _dio = Dio();

  Future<String> uploadImage(XFile file) async {
    // Fallback mock upload if credentials are not customized
    if (cloudName == 'your_cloud_name' || uploadPreset == 'awala_presets') {
      await Future.delayed(const Duration(milliseconds: 500));
      return file.path; // Returns a local blob URL on Flutter Web
    }

    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
        'upload_preset': uploadPreset,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'] as String;
      } else {
        throw 'Failed to upload image to Cloudinary';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cloudinary Upload Error: $e');
      }
      throw 'Image upload failed. Check your connection or Cloudinary configuration.';
    }
  }
}
