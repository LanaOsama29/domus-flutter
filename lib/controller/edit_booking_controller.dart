import 'package:domus/controller/mybooking_controller.dart';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/api_service.dart';
import 'package:domus/model/booking_model.dart';

class EditBookingController extends GetxController {
  final isLoading = false.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final booking = Rx<BookingModel?>(null);
  final apartmentId = 0.obs;
  final dailyPrice = 0.0.obs;
  final monthlyPrice = 0.0.obs;
  final yearlyPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is BookingModel) {
      booking.value = args;
      startDate.value = _parseDate(args.startDate);
      endDate.value = _parseDate(args.endDate);
      apartmentId.value = args.apartmentId;
      _loadApartmentPrices();
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString.split(' ').first);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadApartmentPrices() async {
    try {
      final details = await ApiService.getApartmentDetails(apartmentId.value);
      if (details != null) {
        dailyPrice.value = double.tryParse(details['daily_price']?.toString() ?? '0') ?? 0;
        monthlyPrice.value = double.tryParse(details['monthly_price']?.toString() ?? '0') ?? 0;
        yearlyPrice.value = double.tryParse(details['yearly_price']?.toString() ?? '0') ?? 0;
      }
    } catch (e) {
      print('❌ Error loading apartment prices: $e');
    }
  }

  int get totalDays {
    if (startDate.value == null || endDate.value == null) return 0;
    return endDate.value!.difference(startDate.value!).inDays;
  }

  double get totalPrice {
    if (startDate.value == null || endDate.value == null || totalDays <= 0) {
      return 0;
    }

    final diffDays = totalDays;
    final years = diffDays ~/ 365;
    final months = (diffDays % 365) ~/ 30;
    final days = (diffDays % 365) % 30;

    return (years * yearlyPrice.value) + 
           (months * monthlyPrice.value) + 
           (days * dailyPrice.value);
  }

  Future<void> selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: isStart ? startDate.value ?? DateTime.now() : endDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F6F74),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        startDate.value = picked;
        if (endDate.value != null && endDate.value!.isBefore(picked)) {
          endDate.value = null;
        }
      } else {
        if (startDate.value != null && picked.isAfter(startDate.value!)) {
          endDate.value = picked;
        } else {
          Get.snackbar('Error', 'End date must be after start date');
        }
      }
      update();
    }
  }

// في edit_booking_controller.dart
Future<void> updateBooking() async {
  if (booking.value == null) {
    Get.snackbar('Error', 'Booking data not found');
    return;
  }

  if (startDate.value == null || endDate.value == null) {
    Get.snackbar('Error', 'Please select start and end dates');
    return;
  }

  if (totalDays <= 0) {
    Get.snackbar('Error', 'End date must be after start date');
    return;
  }

  isLoading.value = true;

  try {
    final formattedStart = DateFormat('yyyy-MM-dd').format(startDate.value!);
    final formattedEnd = DateFormat('yyyy-MM-dd').format(endDate.value!);

    print('🔄 Updating booking ID: ${booking.value!.id}');
    
    final response = await ApiService.updateBooking(
      bookingId: booking.value!.id,
      startDate: formattedStart,
      endDate: formattedEnd,
    );

    print('📥 Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ إظهار dialog بدلاً من snackbar
      await _showSuccessDialog();
      
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar(
        '❌ Error',
        error['message'] ?? 'Update failed',
        snackPosition: SnackPosition.TOP,
      );
    }
  } catch (e) {
    print('❌ Update error: $e');
    Get.snackbar(
      '❌ Connection Error',
      'Please check your internet connection',
      snackPosition: SnackPosition.TOP,
    );
  } finally {
    isLoading.value = false;
  }
}

// في edit_booking_controller.dart - عدل دالة _showSuccessDialog
Future<void> _showSuccessDialog() async {
  await Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 30,
          ),
          SizedBox(width: 10),
          Text(
            'Request Sent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your modification request has been sent to the property owner.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          const Text(
            'Waiting for owner approval',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F6F74),
            ),
          ),
          const SizedBox(height: 20),
          // ⚠️ إزالة هذا السطر أو تعليقه
          // Image.asset('assets/images/waiting.gif', height: 80, width: 80),
          
          // بدلاً منه، استخدم أيقونة
          const Icon(
            Icons.access_time,
            size: 60,
            color: Color(0xFF2F6F74),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              _navigateBackToBookings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6F74),
              minimumSize: const Size(150, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Back to Bookings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

// 🆕 دالة للعودة لصفحة الحجوزات
void _navigateBackToBookings() {
  // ✅ الطريقة 1: العودة للصفحة السابقة مع تحديث
  Get.back(result: true); // يعود لصفحة الحجوزات
  
  // ✅ الطريقة 2: تحديث البيانات مباشرة
  final bookingsController = Get.find<BookingsController>();
  bookingsController.refreshBookings();
  
  // ✅ الطريقة 3: إظهار snackbar تأكيد
  Get.snackbar(
    '✅ Success',
    'Modification request sent to owner',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}
}