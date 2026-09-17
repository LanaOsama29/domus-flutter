import 'package:domus/services/api_service.dart';
import 'package:domus/view/rating_dialog_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/apartment_model.dart';
import 'local_rating_controller.dart';
import 'remote_rating_controller.dart'; // ⬅️ **إضافة الاستيراد**

class DetailsController extends GetxController {
  final isLoading = true.obs;
  final isFavorite = false.obs;
  final rating = 0.obs;
  final remoteRating = RemoteRatingController(); // ⬅️ **المتحكم الجديد**

  // ⬇️ **متغيرات جديدة**
  final averageRating = 0.0.obs;
  final ratingsCount = 0.obs;
  final canRate = false.obs;
  final ratingEligibility = <String, dynamic>{}.obs;
  final isCheckingEligibility = false.obs;

  final apartment = Rxn<ApartmentModel>();

  // LocalRatingController instance
  late LocalRatingController ratingController;

  @override
  void onInit() {
    super.onInit();

    // تهيئة LocalRatingController
    ratingController = Get.find<LocalRatingController>();

    // ⬇️ **تفعيل RemoteRatingController**
    Get.put(remoteRating, permanent: true);

    final int id = Get.arguments;
    loadApartment(id);
  }

  Future<void> loadApartment(int id) async {
    isLoading.value = true;
    print("🔍 Loading apartment details for ID: $id");

    try {
      final result = await ApiService.getApartmentDetails(id);

      if (result != null) {
        print("✅ Raw API response for apartment $id:");
        print("Name: ${result['name_of_apartment']}");
        print("Average Rating: ${result['average_rating']}");
        print("Ratings Count: ${result['ratings_count']}");

        try {
          apartment.value = ApartmentModel.fromJson(result);
          print("✅ Apartment model created successfully");

          // ⬇️ **تحديث بيانات التقييم من الـ API**
          if (result['average_rating'] != null) {
            averageRating.value = result['average_rating'].toDouble();
          }
          if (result['ratings_count'] != null) {
            ratingsCount.value = result['ratings_count'].toInt();
          }

          print("✅ Average Rating: ${averageRating.value}");
          print("✅ Ratings Count: ${ratingsCount.value}");
        } catch (e) {
          print("❌ ERROR in ApartmentModel.fromJson: $e");
        }
      } else {
        print("❌ No data received from API for apartment $id");
      }
    } catch (e) {
      print("❌ ERROR in loadApartment: $e");
    }

    isLoading.value = false;

    // تحميل التقييم المحلي بعد تحميل الشقة
    loadLocalRating();

    // ⬇️ **التحقق من أهلية التقييم**
    checkRatingEligibility(id);
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void setRating(int value) {
    rating.value = value;

    if (apartment.value != null) {
      // إذا كان مؤهلاً للتقييم، أرسل للسيرفر
      if (canRate.value) {
        submitRatingToServer(value);
      } else {
        // حفظ محلي فقط للعرض
        ratingController.saveRating(apartment.value!.id, value);

        // ⬇️ **عرض رسالة للمستخدم**
        if (!canRate.value && ratingEligibility['reason'] != null) {
          Get.snackbar(
            'تنبيه',
            ratingEligibility['reason'],
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        }
      }
    }
  }

  // تحميل التقييم المحلي للشقة
  void loadLocalRating() {
    if (apartment.value != null) {
      print('🏠 تحميل تقييم محلي للشقة: ${apartment.value!.id}');
      final savedRating = ratingController.getRating(apartment.value!.id);
      print('⭐ التقييم المحفوظ: $savedRating');
      rating.value = savedRating;
      print('✅ تم تحديث rating.value إلى: ${rating.value}');
    } else {
      print('⚠️ لا يمكن تحميل التقييم - الشقة غير متوفرة');
    }
  }

  // ⬇️ **دالة جديدة: التحقق من أهلية التقييم**
  Future<void> checkRatingEligibility(int apartmentId) async {
    isCheckingEligibility.value = true;

    try {
      final result = await remoteRating.checkEligibility(apartmentId);

      if (result['success'] == true) {
        ratingEligibility.value = result;
        canRate.value = result['can_rate'] ?? false;

        print('🔍 Eligibility Check Result:');
        print('  - Can Rate: ${canRate.value}');
        print('  - Has Booking: ${result['has_booking']}');
        print('  - Already Rated: ${result['already_rated']}');
        print('  - Reason: ${result['reason']}');
      }
    } catch (e) {
      print('❌ Error checking eligibility: $e');
      canRate.value = false;
      ratingEligibility.value = {'reason': 'خطأ في التحقق من الأهلية'};
    }

    isCheckingEligibility.value = false;
  }

  // ⬇️ **دالة جديدة: إرسال التقييم للسيرفر**
  Future<void> submitRatingToServer(int ratingValue, {String? comment}) async {
    if (apartment.value == null) return;

    final result = await remoteRating.submitRating(
      apartmentId: apartment.value!.id,
      rating: ratingValue,
      comment: comment,
    );

    if (result['success'] == true) {
      // تحديث البيانات المحلية
      ratingController.saveRating(apartment.value!.id, ratingValue);

      // تحديث متوسط التقييم
      averageRating.value = result['average_rating'] ?? 0.0;
      ratingsCount.value = result['ratings_count'] ?? 0;

      // تحديث حالة الأهلية - إعادة فحص من السيرفر
      await checkRatingEligibility(apartment.value!.id);

      // تحديث فوري لبيانات التقييم
      await refreshRatingDataAfterSubmission();

      // إشعار النجاح
      Get.snackbar(
        'نجاح',
        'تم إرسال التقييم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // ⬇️ **دالة جديدة: تحديث بيانات التقييم من السيرفر**
  Future<void> refreshRatingData() async {
    if (apartment.value == null) return;

    try {
      final result = await remoteRating.getAverageRating(apartment.value!.id);

      if (result['success'] == true) {
        averageRating.value = result['average_rating'];
        ratingsCount.value = result['ratings_count'];

        print('🔄 Rating data refreshed:');
        print('  - Average: ${averageRating.value}');
        print('  - Count: ${ratingsCount.value}');
      }
    } catch (e) {
      print('❌ Error refreshing rating data: $e');
    }
  }

  // ⬇️ **دالة جديدة: تحديث فوري لبيانات التقييم بعد الإرسال**
  Future<void> refreshRatingDataAfterSubmission() async {
    if (apartment.value == null) return;

    try {
      // تحديث بيانات الشقة من الـ API للحصول على التقييمات المحدثة
      final result = await ApiService.getApartmentDetails(apartment.value!.id);

      if (result != null) {
        // تحديث متوسط التقييم وعدد التقييمات
        if (result['average_rating'] != null) {
          averageRating.value = result['average_rating'].toDouble();
        }
        if (result['ratings_count'] != null) {
          ratingsCount.value = result['ratings_count'].toInt();
        }

        print('🔄 Rating data refreshed after submission:');
        print('  - Average: ${averageRating.value}');
        print('  - Count: ${ratingsCount.value}');
      }
    } catch (e) {
      print('❌ Error refreshing rating data after submission: $e');
    }
  }

  // ⬇️ **دالة جديدة: عرض dialog للتقييم مع تعليق**
  void showRatingDialog() {
    if (apartment.value == null || !canRate.value) return;

    Get.defaultDialog(
      title: 'تقييم الشقة',
      content: RatingDialogContent(
        onSubmit: (rating, comment) {
          submitRatingToServer(rating, comment: comment);
          Get.back();
        },
      ),
      textCancel: 'إلغاء',
      textConfirm: 'تأكيد',
      onConfirm: () {
        // يتم التعامل معه في الـ RatingDialogContent
      },
    );
  }

  // ⬇️
  String get ratingText {
    if (ratingsCount.value == 0) {
      return 'لا توجد تقييمات بعد';
    }
    return '${averageRating.value.toStringAsFixed(1)} ⭐ (${ratingsCount.value} تقييم)';
  }
}
