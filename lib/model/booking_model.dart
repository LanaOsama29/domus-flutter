import 'package:domus/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingModel {
  final int id;
  final int apartmentId;
  final String apartmentName;
  final String apartmentImage;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status; 
  final String? paymentStatus; 
  final String? rejectionReason;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final String renterName; 
  final bool isModified;
  final DateTime? modifiedAt;
  final String? modificationNotes;

  BookingModel({
    required this.id,
    required this.apartmentId,
    required this.apartmentName,
    required this.apartmentImage,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.paymentStatus,
    this.rejectionReason,
    this.approvedAt,
    this.createdAt,
    this.renterName = 'None', 
    this.isModified = false,
    this.modifiedAt,
    this.modificationNotes,
  });
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print('🔄 BookingModel.fromJson - مفاتيح JSON: ${json.keys.toList()}');
    print('🔄 JSON كامل: $json');
    String getRenterName() {
      try {
        if (json['renter'] is Map) {
          final firstName = json['renter']['first_name']?.toString() ?? '';
          final lastName = json['renter']['last_name']?.toString() ?? '';
          final name = '$firstName $lastName'.trim();
          return name.isNotEmpty ? name : 'غير معروف';
        }
      } catch (e) {
        print('⚠️ خطأ في استخراج اسم المستأجر: $e');
      }
      return 'None';
    }
    String getApartmentName() {
      try {
        if (json['apartment'] is Map) {
          return json['apartment']['name_of_apartment']?.toString() ??
              json['apartment']['name']?.toString() ??
              'غير معروف';
        }
        if (json['apartment'] is String) {
          return json['apartment'];
        }
        if (json['apartment_name'] != null) {
          return json['apartment_name'].toString();
        }
      } catch (e) {
        print('⚠️ خطأ في استخراج اسم الشقة: $e');
      }
      return 'شقة غير معروفة';
    }
    String getApartmentImage() {
      try {
        if (json['apartment'] is Map) {
          if (json['apartment']['first_image'] != null) {
            if (json['apartment']['first_image'] is Map) {
              final image =
                  json['apartment']['first_image']['image']?.toString();
              if (image != null && image.isNotEmpty) {
                return _buildImageUrl(image);
              }
            } else if (json['apartment']['first_image'] is String) {
              final image = json['apartment']['first_image'].toString();
              if (image.isNotEmpty) {
                return _buildImageUrl(image);
              }
            }
          }
        }
        if (json['apartment'] is Map && json['apartment']['images'] is List) {
          final images = json['apartment']['images'] as List;
          if (images.isNotEmpty && images[0] is Map) {
            final image = images[0]['image']?.toString();
            if (image != null && image.isNotEmpty) {
              return _buildImageUrl(image);
            }
          }
        }
      } catch (e) {
        print('⚠️ خطأ في استخراج صورة الشقة: $e');
      }
      return '';
    }
    double parseTotalPrice(dynamic price) {
      if (price == null) return 0.0;
      if (price is double) return price;
      if (price is int) return price.toDouble();
      if (price is String) {
        try {
          return double.tryParse(price.replaceAll(',', '')) ?? 0.0;
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    try {
      final model = BookingModel(
        id: json['id']?.toInt() ?? 0,
        apartmentId: json['apartment_id']?.toInt() ?? 0,
        apartmentName: getApartmentName(),
        apartmentImage: getApartmentImage(),
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        totalPrice: parseTotalPrice(json['total_price']),
        status: (json['status']?.toString() ?? 'pending').toLowerCase(),
        paymentStatus: json['payment_status']?.toString(),
        rejectionReason: json['rejection_reason']?.toString(),
        approvedAt:
            json['approved_at'] != null
                ? DateTime.tryParse(json['approved_at'].toString())
                : null,
        createdAt:
            json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString())
                : null,
        renterName: getRenterName(), 
        isModified: json['is_modified'] ?? json['isModified'] ?? false,
      modifiedAt: json['modified_at'] != null 
          ? DateTime.tryParse(json['modified_at'].toString()) 
          : null,
      modificationNotes: json['modification_notes']?.toString() ?? 
                       json['modificationNotes']?.toString(),
      );

      print('✅ BookingModel created: ${model.id} - ${model.apartmentName}');
      return model;
    } catch (e, stackTrace) {
      print('❌ خطأ في BookingModel.fromJson: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
  static String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    print('🖼️ Building URL for image path: "$imagePath"');

    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

   
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/storage/')) {
      cleanPath = cleanPath.substring(1); 
    }
    if (cleanPath.startsWith('storage/')) {
      
    } else {
      cleanPath = 'storage/$cleanPath';
    }

    const String baseUrl = ApiConfig.baseUrl;
    String finalUrl = '$baseUrl/$cleanPath';

    print('🖼️ Final URL: $finalUrl');
    return finalUrl;
  }

  String get formattedStartDate {
    if (startDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(startDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return startDate;
    }
  }

  String get formattedEndDate {
    if (endDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(endDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return endDate;
    }
  }

  String get formattedTotalPrice {
    return '${NumberFormat('#,##0').format(totalPrice)} \$';
  }
  // في booking_model.dart - أضف هذه الدالة
String get formattedModifiedAt {
  if (modifiedAt == null) return '-';
  try {
    return DateFormat('dd/MM/yyyy HH:mm').format(modifiedAt!);
  } catch (e) {
    return '-';
  }
}

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981); 
      case 'pending':
        return const Color(0xFFF59E0B); 
      case 'cancelled':
        return const Color(0xFFEF4444); 
      case 'rejected':
        return const Color(0xFF6B7280); 
      case 'completed':
        return const Color(0xFF3B82F6); 
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'approved';
      case 'pending':
        return 'pending';
      case 'cancelled':
        return 'cancelled';
      case 'rejected':
        return 'rejected';
      case 'completed':
        return 'completed';
      default:
        return status;
    }
  }

  bool get isActive =>
      status.toLowerCase() == 'approved' || status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCompleted => status.toLowerCase() == 'completed';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'apartment_name': apartmentName,
      'apartment_image': apartmentImage,
      'start_date': startDate,
      'end_date': endDate,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'renter_name': renterName,
    };
  }
}
