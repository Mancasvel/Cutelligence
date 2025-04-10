import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../main.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Reduce quality to save storage
        maxWidth: 1080,
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Upload image to Supabase Storage
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a unique file name
      final fileExt = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExt';
      final filePath = '${user.id}/$fileName';
      
      // Upload file to Supabase Storage
      await supabase.storage
          .from('rostros')
          .upload(filePath, imageFile);
      
      // Get the public URL
      final imageUrl = supabase.storage
          .from('rostros')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Show image selection dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Take a photo'),
                      ],
                    ),
                  ),
                  onTap: () async {
                    final File? image = await pickImageFromCamera();
                    Navigator.of(context).pop(image);
                  },
                ),
                const Divider(),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Choose from gallery'),
                      ],
                    ),
                  ),
                  onTap: () async {
                    final File? image = await pickImageFromGallery();
                    Navigator.of(context).pop(image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 