import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/face_analysis_service.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({Key? key}) : super(key: key);

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _clients = [];
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy - h:mm a');

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> clients = await SupabaseService.getClientAnalysis();
      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: ${error.toString()}'),
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
        title: const Text('Client History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? _buildEmptyState()
              : _buildClientList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No client analyses yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze a face to start building your history',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return RefreshIndicator(
      onRefresh: _loadClients,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          final DateTime date = DateTime.parse(client['fecha']);
          final String faceShape = client['forma_rostro'] ?? 'Unknown';
          final String imageUrl = client['imagen_url'] ?? '';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.face, color: Colors.grey),
              ),
              title: Text(
                'Face Shape: ${FaceAnalysisService.stringToFaceShape(faceShape) != FaceShape.unknown ? faceShape : "Unknown"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_dateFormat.format(date)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (client['recomendaciones'] != null)
                    Text(
                      'Recommendations: ${_formatRecommendations(client['recomendaciones'])}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Future enhancement: Show full client details
              },
            ),
          );
        },
      ),
    );
  }

  String _formatRecommendations(dynamic recommendations) {
    if (recommendations is List) {
      return recommendations.join(', ');
    } else if (recommendations is Map) {
      return recommendations.values.join(', ');
    }
    return 'No recommendations';
  }
} 