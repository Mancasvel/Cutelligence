import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../services/face_analysis_service.dart';
import '../services/supabase_service.dart';
import '../widgets/recommendation_card.dart';

class FaceAnalysisScreen extends StatefulWidget {
  const FaceAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<FaceAnalysisScreen> createState() => _FaceAnalysisScreenState();
}

class _FaceAnalysisScreenState extends State<FaceAnalysisScreen> {
  File? _selectedImage;
  String? _imageUrl;
  bool _isAnalyzing = false;
  bool _isUploading = false;
  bool _analysisDone = false;
  FaceShape _faceShape = FaceShape.unknown;
  List<Map<String, String>> _recommendations = [];

  Future<void> _pickImage() async {
    final File? image = await ImageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _analysisDone = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Analyze face shape
      final FaceShape detectedShape = await FaceAnalysisService.analyzeFaceShape(_selectedImage!);
      
      // Get recommendations based on face shape
      final List<Map<String, String>> recs = FaceAnalysisService.getRecommendations(detectedShape);

      // Upload image to Supabase
      setState(() {
        _isUploading = true;
      });
      
      final String? url = await ImageService.uploadImage(_selectedImage!);
      
      if (url != null) {
        _imageUrl = url;
        
        // Save analysis to Supabase
        await SupabaseService.saveClientAnalysis(
          imageUrl: url,
          faceShape: FaceAnalysisService.faceShapeToString(detectedShape),
          recommendations: recs.map((rec) => rec['name']!).toList(),
        );
      }

      // Update UI
      if (mounted) {
        setState(() {
          _faceShape = detectedShape;
          _recommendations = recs;
          _analysisDone = true;
          _isAnalyzing = false;
          _isUploading = false;
        });
      }
    } catch (error) {
      // Handle errors
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Analysis'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Selection Area
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Select Image'),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: _pickImage,
                              child: const Icon(Icons.refresh),
                            ),
                          ),
                        ],
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Analysis Button
              if (_selectedImage != null && !_analysisDone)
                ElevatedButton(
                  onPressed: _isAnalyzing || _isUploading ? null : _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isAnalyzing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Analyzing face...'),
                          ],
                        )
                      : _isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Saving results...'),
                              ],
                            )
                          : const Text('Analyze Face'),
                ),
                
              // Results Section
              if (_analysisDone) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Face Shape: ${FaceAnalysisService.faceShapeToString(_faceShape)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here are some haircut recommendations for ${FaceAnalysisService.faceShapeToString(_faceShape)} face shape:',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Recommendations
                ..._recommendations.map((recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: RecommendationCard(
                    title: recommendation['name']!,
                    description: recommendation['description']!,
                    imagePath: recommendation['image']!,
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 