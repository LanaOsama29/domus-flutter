import 'package:domus/services/api_config.dart';

class ApartmentModel {
  final int id;
  final String name;
  final String? province;
  final String? city;
  final String? address;
  final String? description;
  final double? dailyPrice;
  final double? monthlyPrice;
  final double? yearlyPrice;
  final List<String> images;
  final String? ownerName;
  final String? ownerImage;
  final double? averageRating;
  final int? ratingsCount;
  ApartmentModel({
    required this.id,
    required this.name,
    required this.province,
    required this.city,
    required this.address,
    this.description,
    this.dailyPrice,
    this.monthlyPrice,
    this.yearlyPrice,
    required this.images,
    this.ownerName,
    this.ownerImage,
     this.averageRating,
    this.ratingsCount,
  });
  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    print("🔄 Creating ApartmentModel from JSON...");
    print("🔄 JSON keys: ${json.keys.toList()}");
    print(
      "🔄 JSON source: ${json.containsKey('name_of_apartment') ? 'showAll/showOne' : 'owner/apartments'}",
    );
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.tryParse(value.replaceAll(',', ''));
        } catch (e) {
          print("⚠️ Error parsing double from string '$value': $e");
          return null;
        }
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    List<String> imageUrls = [];
    try {
      final isFromOwnerEndpoint =
          json.containsKey('name') && !json.containsKey('name_of_apartment');
      print(
        "🔍 Data source: ${isFromOwnerEndpoint ? 'owner/apartments' : 'showAll/showOne'}",
      );
      if (isFromOwnerEndpoint) {
        print("📷 Processing owner/apartments data");
        if (json.containsKey('image') && json['image'] != null) {
          String imagePath = json['image'].toString().trim();
          print("📷 Owner image path: $imagePath");
          if (imagePath.startsWith('http')) {
            imageUrls.add(imagePath);
          } else {
            String fullUrl = _buildImageUrl(imagePath);
            if (fullUrl.isNotEmpty) imageUrls.add(fullUrl);
          }
        }
        if (json['images'] != null && json['images'] is List) {
          print(
            "📷 Owner has images array with ${json['images'].length} items",
          );

          for (var img in json['images']) {
            try {
              if (img != null) {
                String imagePath;
                if (img is Map && img['image'] != null) {
                  imagePath = img['image'].toString().trim();
                } else if (img is String) {
                  imagePath = img.trim();
                } else {
                  continue;
                }
                if (imagePath.startsWith('http')) {
                  imageUrls.add(imagePath);
                } else {
                  String fullUrl = _buildImageUrl(imagePath);
                  if (fullUrl.isNotEmpty) imageUrls.add(fullUrl);
                }
              }
            } catch (e) {
              print("⚠️ Error processing owner image item: $e");
            }
          }
        }
      } else {
        print("📷 Processing showAll/showOne data");

        if (json.containsKey('first_image') && json['first_image'] != null) {
          dynamic firstImage = json['first_image'];

          if (firstImage is Map && firstImage['image'] != null) {
            String imagePath = firstImage['image'].toString().trim();
            String fullUrl = _buildImageUrl(imagePath);
            if (fullUrl.isNotEmpty) imageUrls.add(fullUrl);
          }
        } else if (json.containsKey('image') && json['image'] != null) {
          // Handle favorites API response
          String imagePath = json['image'].toString().trim();
          String fullUrl = _buildImageUrl(imagePath);
          if (fullUrl.isNotEmpty) imageUrls.add(fullUrl);
        } else if (json['images'] != null && json['images'] is List) {
          print("📷 Using images array with ${json['images'].length} items");

          for (var img in json['images']) {
            try {
              if (img != null) {
                String imagePath;
                if (img is Map && img['image'] != null) {
                  imagePath = img['image'].toString().trim();
                } else if (img is String) {
                  imagePath = img.trim();
                } else {
                  continue;
                }

                String fullUrl = _buildImageUrl(imagePath);
                if (fullUrl.isNotEmpty) imageUrls.add(fullUrl);
              }
            } catch (e) {
              print("⚠️ Error processing individual image: $e");
            }
          }
        }
      }
    } catch (e) {
      print("❌ ERROR processing images: $e");
    }
    if (imageUrls.isEmpty) {
      print("⚠️ No images found, adding placeholder");
      imageUrls.add('https://via.placeholder.com/600x400?text=No+Image');
    }

    print("✅ Final image URLs count: ${imageUrls.length}");
    if (imageUrls.isNotEmpty) {
      print("✅ First image URL: ${imageUrls.first}");
    }

    String? ownerImageUrl;
    try {
      if (json['owner_image'] != null &&
          json['owner_image'].toString().isNotEmpty) {
        String ownerPath = json['owner_image'].toString().trim();
        if (ownerPath.startsWith('http')) {
          ownerImageUrl = ownerPath;
        } else {
          ownerImageUrl = _buildImageUrl(ownerPath);
        }
      }
    } catch (e) {
      print("⚠️ Error processing owner image: $e");
    }

    try {
      return ApartmentModel(
        id: json['id']?.toInt() ?? 0,
        name:
            json['name_of_apartment']?.toString() ??
            json['name']?.toString() ??
            'غير معروف',
        province: json['province']?.toString() ?? 'غير معروف',
        city: json['city']?.toString() ?? 'غير معروف',
        address: json['address']?.toString() ?? 'غير معروف',
        description: json['description']?.toString(),

        dailyPrice: parseDouble(json['daily_price']),
        monthlyPrice: parseDouble(json['monthly_price']),
        yearlyPrice: parseDouble(json['yearly_price']),

        images: imageUrls,

        ownerName:
            (() {
              final ownerNameRaw =
                  json['owner_name']?.toString() ??
                  '${json['owner']?['first_name'] ?? ''} ${json['owner']?['last_name'] ?? ''}';
              final trimmed = ownerNameRaw.trim();
              return trimmed.isNotEmpty ? trimmed : 'غير معروف';
            })(),
        ownerImage: ownerImageUrl,
         averageRating: parseDouble(json['average_rating']),
        ratingsCount: parseInt(json['ratings_count']),
      );
    } catch (e) {
      print("❌ FATAL ERROR creating ApartmentModel: $e");
      rethrow;
    }
  }
  static String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    print("🖼️ Original path: $imagePath");
    final baseUrl = ApiConfig.baseUrl;
    final storagePrefix = '$baseUrl/storage/';
    if (imagePath.contains('$storagePrefix$storagePrefix')) {
      print("⚠️ Detected duplicated baseUrl + storage/");
      final fixedPath = imagePath.replaceFirst(
        '$storagePrefix$storagePrefix',
        storagePrefix,
      );
      print("✅ Fixed to: $fixedPath");
      return fixedPath;
    }
    if (imagePath.contains('$baseUrl$baseUrl')) {
      print("⚠️ Detected duplicated baseUrl");
      final fixedPath = imagePath.replaceFirst('$baseUrl$baseUrl', baseUrl);
      print("✅ Fixed to: $fixedPath");
      return fixedPath;
    }

    if (imagePath.startsWith('http')) {
      if (imagePath.startsWith(baseUrl)) {
        print("✅ Already a full URL with baseUrl, returning as is");
        return imagePath;
      }
      print("✅ Full URL from different source, returning as is");
      return imagePath;
    }

    String cleanPath = imagePath.replaceAll(RegExp(r'^/+'), '');
    while (cleanPath.startsWith('storage/storage/')) {
      cleanPath = cleanPath.replaceFirst('storage/storage/', 'storage/');
      print("🔄 Removed duplicate 'storage/' prefix");
    }
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }
    final fullUrl = '$baseUrl/$cleanPath';
    print("✅ Built final URL: $fullUrl");
    return fullUrl;
  }
  String get ratingText {
    if (averageRating == null || averageRating == 0 || ratingsCount == 0) {
      return 'لا توجد تقييمات بعد';
    }
    return '${averageRating!.toStringAsFixed(1)} ⭐ ($ratingsCount تقييم)';
  }
  
  // ⬇️ **دالة التحقق من وجود تقييم**
  bool get hasRating => averageRating != null && averageRating! > 0;
}
