import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class RemoteRatingController extends GetxController {
  final box = GetStorage();
  
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  
  // Submit rating to server
  Future<Map<String, dynamic>> submitRating({
    required int apartmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      isSubmitting.value = true;
      
      final response = await ApiService.submitRating(
        apartmentId: apartmentId,
        rating: rating,
        comment: comment,
      );
      
      if (response.statusCode == 201) {
        // Save locally that user rated
        box.write('has_rated_$apartmentId', true);
        box.write('user_rating_$apartmentId', rating);
        if (comment != null) {
          box.write('user_comment_$apartmentId', comment);
        }
        
        final data = jsonDecode(response.body);
        isSubmitting.value = false;
        
        Get.snackbar(
          'Success',
          data['message'] ?? 'Rating submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return {
          'success': true,
          'data': data,
          'average_rating': data['average_rating'] ?? 0.0,
          'ratings_count': data['ratings_count'] ?? 0,
        };
      } else {
        final error = jsonDecode(response.body);
        isSubmitting.value = false;
        
        Get.snackbar(
          'Error',
          error['message'] ?? 'Failed to submit rating',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
        return {
          'success': false,
          'error': error['message'],
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      isSubmitting.value = false;
      
      Get.snackbar(
        'Error',
        'Unable to connect to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Get apartment average rating
  Future<Map<String, dynamic>> getAverageRating(int apartmentId) async {
    try {
      isLoading.value = true;
      final data = await ApiService.getAverageRating(apartmentId);
      isLoading.value = false;
      
      return {
        'success': true,
        'average_rating': data['average_rating'] ?? 0.0,
        'ratings_count': data['ratings_count'] ?? 0,
        'rating_text': data['rating_text'] ?? 'No ratings yet',
      };
    } catch (e) {
      isLoading.value = false;
      
      return {
        'success': false,
        'error': e.toString(),
        'average_rating': 0.0,
        'ratings_count': 0,
        'rating_text': 'Error loading ratings',
      };
    }
  }
  
  // Check user eligibility for rating
  Future<Map<String, dynamic>> checkEligibility(int apartmentId) async {
    try {
      final data = await ApiService.checkRatingEligibility(apartmentId);
      
      return {
        'success': true,
        'can_rate': data['can_rate'] ?? false,
        'has_booking': data['has_booking'] ?? false,
        'already_rated': data['already_rated'] ?? false,
        'reason': data['reason'] ?? 'Unknown',
      };
    } catch (e) {
      return {
        'success': false,
        'can_rate': false,
        'reason': 'Connection error',
        'error': e.toString(),
      };
    }
  }
  
  // Check if user rated the apartment locally
  bool hasUserRatedLocally(int apartmentId) {
    return box.read('has_rated_$apartmentId') ?? false;
  }
  
  // Get user's local rating
  Map<String, dynamic>? getUserLocalRating(int apartmentId) {
    if (!hasUserRatedLocally(apartmentId)) {
      return null;
    }
    
    return {
      'rating': box.read('user_rating_$apartmentId'),
      'comment': box.read('user_comment_$apartmentId'),
    };
  }
  
  // Get apartment ratings (with pagination)
  Future<Map<String, dynamic>> getApartmentRatings(int apartmentId, {int page = 1}) async {
    try {
      isLoading.value = true;
      final data = await ApiService.getApartmentRatings(apartmentId, page: page);
      isLoading.value = false;
      
      return {
        'success': true,
        'data': data,
        'ratings': data['ratings']['data'] ?? [],
        'apartment': data['apartment'],
        'summary': data['summary'] ?? {},
        'pagination': {
          'current_page': data['ratings']['current_page'] ?? 1,
          'last_page': data['ratings']['last_page'] ?? 1,
          'total': data['ratings']['total'] ?? 0,
        },
      };
    } catch (e) {
      isLoading.value = false;
      
      return {
        'success': false,
        'error': e.toString(),
        'ratings': [],
        'apartment': null,
        'summary': {},
      };
    }
  }
  
  // Delete rating
  Future<Map<String, dynamic>> deleteRating(int ratingId, int apartmentId) async {
    try {
      final response = await ApiService.deleteRating(ratingId);
      
      if (response.statusCode == 200) {
        // Delete local rating
        box.remove('has_rated_$apartmentId');
        box.remove('user_rating_$apartmentId');
        box.remove('user_comment_$apartmentId');
        
        final data = jsonDecode(response.body);
        
        Get.snackbar(
          'Success',
          'Rating deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return {
          'success': true,
          'data': data,
          'average_rating': data['average_rating'] ?? 0.0,
          'ratings_count': data['ratings_count'] ?? 0,
        };
      } else {
        final error = jsonDecode(response.body);
        
        Get.snackbar(
          'Error',
          error['message'] ?? 'Failed to delete rating',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
        return {
          'success': false,
          'error': error['message'],
        };
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to connect to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Update local rating (for temporary cases)
  void saveLocalRating(int apartmentId, int rating, {String? comment}) {
    box.write('has_rated_$apartmentId', true);
    box.write('user_rating_$apartmentId', rating);
    if (comment != null) {
      box.write('user_comment_$apartmentId', comment);
    }
  }
}