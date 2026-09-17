import 'package:domus/services/api_config.dart';

class FavoriteModel {
  final int id;
  final String name;
  final String province;
  final String city;
  final String image;
  
  FavoriteModel({
    required this.id,
    required this.name,
    required this.province,
    required this.city,
    required this.image,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id']?.toInt() ?? 0,
      name: json['name_of_apartment']?.toString() ?? 'غير معروف',
      province: json['province']?.toString() ?? 'غير معروف',
      city: json['city']?.toString() ?? 'غير معروف',
      image: _buildImageUrl(json['image']?.toString() ?? ''),
    );
  }
  static String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    String cleanPath = imagePath.replaceAll(RegExp(r'^/+'), '');
    
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }
    
    return '${ApiConfig.baseUrl}/$cleanPath';
  }
}