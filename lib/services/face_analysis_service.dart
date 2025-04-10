import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

enum FaceShape {
  oval,
  round,
  square,
  rectangle,
  heart,
  diamond,
  triangle,
  unknown
}

class FaceAnalysisService {
  static final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Analyze face shape from image
  static Future<FaceShape> analyzeFaceShape(File imageFile) async {
    try {
      // Create input image from file
      final InputImage inputImage = InputImage.fromFile(imageFile);
      
      // Process the image
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      // Check if any face was detected
      if (faces.isEmpty) {
        debugPrint('No face detected');
        return FaceShape.unknown;
      }
      
      // For simplicity, we'll just use the first face detected
      final Face face = faces.first;
      
      // In a real-world application, you would analyze the face contours 
      // to determine face shape more accurately
      // For now, we'll simulate this with a basic approach
      return _determineFaceShape(face);
    } catch (e) {
      debugPrint('Error analyzing face: $e');
      return FaceShape.unknown;
    }
  }

  // A simplified approach to determine face shape
  // In a production app, this would be more sophisticated
  static FaceShape _determineFaceShape(Face face) {
    // This is a simplified approach that would need more refinement
    // In a real ML implementation:
    // - Analyze the ratio of face width to height
    // - Analyze jawline shape
    // - Analyze forehead width relative to chin
    
    // For this demo, we'll simulate with random results
    // In a real app, you'd extract actual measurements from face.contours
    
    // Randomly pick a face shape for demo purposes
    final List<FaceShape> shapes = [
      FaceShape.oval,
      FaceShape.round,
      FaceShape.square,
      FaceShape.rectangle,
      FaceShape.heart,
      FaceShape.diamond,
      FaceShape.triangle,
    ];
    
    final Random random = Random();
    return shapes[random.nextInt(shapes.length)];
  }

  // Get haircut recommendations based on face shape
  static List<Map<String, String>> getRecommendations(FaceShape faceShape) {
    switch (faceShape) {
      case FaceShape.oval:
        return [
          {
            'name': 'Pompadour',
            'description': 'Volume on top with shorter sides',
            'image': 'assets/images/pompadour.jpg',
          },
          {
            'name': 'Textured Crop',
            'description': 'Short textured top with faded sides',
            'image': 'assets/images/textured_crop.jpg',
          },
          {
            'name': 'Quiff',
            'description': 'Voluminous top swept upward and back',
            'image': 'assets/images/quiff.jpg',
          },
        ];
      
      case FaceShape.round:
        return [
          {
            'name': 'Pompadour',
            'description': 'Height on top to elongate the face',
            'image': 'assets/images/pompadour.jpg',
          },
          {
            'name': 'Faux Hawk',
            'description': 'Height and texture through the center',
            'image': 'assets/images/faux_hawk.jpg',
          },
          {
            'name': 'Side Part',
            'description': 'Clean part with length on top',
            'image': 'assets/images/side_part.jpg',
          },
        ];
      
      case FaceShape.square:
        return [
          {
            'name': 'Textured Crop',
            'description': 'Softens angles with texture on top',
            'image': 'assets/images/textured_crop.jpg',
          },
          {
            'name': 'Buzz Cut',
            'description': 'Emphasizes strong jaw and cheekbones',
            'image': 'assets/images/buzz_cut.jpg',
          },
          {
            'name': 'Slicked Back',
            'description': 'Sophisticated style highlighting facial structure',
            'image': 'assets/images/slicked_back.jpg',
          },
        ];
      
      case FaceShape.rectangle:
        return [
          {
            'name': 'Textured Fringe',
            'description': 'Breaks up height with horizontal element',
            'image': 'assets/images/textured_fringe.jpg',
          },
          {
            'name': 'Side Swept',
            'description': 'Volume and movement to balance face length',
            'image': 'assets/images/side_swept.jpg',
          },
          {
            'name': 'Mid-Length Layered',
            'description': 'Adds width to narrow face',
            'image': 'assets/images/layered.jpg',
          },
        ];
      
      case FaceShape.heart:
        return [
          {
            'name': 'Textured Quiff',
            'description': 'Balances wider forehead with volume',
            'image': 'assets/images/textured_quiff.jpg',
          },
          {
            'name': 'Swept Fringe',
            'description': 'Covers forehead and adds width at jawline',
            'image': 'assets/images/swept_fringe.jpg',
          },
          {
            'name': 'Medium Length Swept',
            'description': 'Balance with a side part and volume',
            'image': 'assets/images/medium_swept.jpg',
          },
        ];
      
      case FaceShape.diamond:
        return [
          {
            'name': 'Fringe',
            'description': 'Softens narrow forehead and highlights cheekbones',
            'image': 'assets/images/fringe.jpg',
          },
          {
            'name': 'Textured Medium Length',
            'description': 'Adds width to balance narrow chin and forehead',
            'image': 'assets/images/textured_medium.jpg',
          },
          {
            'name': 'Side Part',
            'description': 'Clean style that works well with angular features',
            'image': 'assets/images/side_part.jpg',
          },
        ];
      
      case FaceShape.triangle:
        return [
          {
            'name': 'Volume on Top',
            'description': 'Balances wider jaw with volume on top',
            'image': 'assets/images/volume_top.jpg',
          },
          {
            'name': 'Textured Crop',
            'description': 'Shorter on sides with textured top',
            'image': 'assets/images/textured_crop.jpg',
          },
          {
            'name': 'Pompadour',
            'description': 'Height and volume to balance wider jaw',
            'image': 'assets/images/pompadour.jpg',
          },
        ];
      
      case FaceShape.unknown:
      default:
        return [
          {
            'name': 'Classic Taper',
            'description': 'Versatile style that works for most face shapes',
            'image': 'assets/images/classic_taper.jpg',
          },
          {
            'name': 'Textured Crop',
            'description': 'Modern, adaptable style',
            'image': 'assets/images/textured_crop.jpg',
          },
          {
            'name': 'Buzz Cut',
            'description': 'Simple, low-maintenance style',
            'image': 'assets/images/buzz_cut.jpg',
          },
        ];
    }
  }

  // Helper function to convert FaceShape enum to string
  static String faceShapeToString(FaceShape shape) {
    switch (shape) {
      case FaceShape.oval: return 'Oval';
      case FaceShape.round: return 'Round';
      case FaceShape.square: return 'Square';
      case FaceShape.rectangle: return 'Rectangle';
      case FaceShape.heart: return 'Heart';
      case FaceShape.diamond: return 'Diamond';
      case FaceShape.triangle: return 'Triangle';
      case FaceShape.unknown: return 'Unknown';
    }
  }

  // Helper function to convert string to FaceShape enum
  static FaceShape stringToFaceShape(String shape) {
    shape = shape.toLowerCase();
    if (shape == 'oval') return FaceShape.oval;
    if (shape == 'round') return FaceShape.round;
    if (shape == 'square') return FaceShape.square;
    if (shape == 'rectangle') return FaceShape.rectangle;
    if (shape == 'heart') return FaceShape.heart;
    if (shape == 'diamond') return FaceShape.diamond;
    if (shape == 'triangle') return FaceShape.triangle;
    return FaceShape.unknown;
  }
} 