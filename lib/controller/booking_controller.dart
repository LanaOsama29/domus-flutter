import 'dart:convert';

import 'package:domus/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  final isLoading = false.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  final apartment = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadApartmentData();
  }

  void _loadApartmentData() {
    final args = Get.arguments;
    print('📥 Booking arguments received: $args');

    if (args != null && args is Map<String, dynamic>) {
      apartment.value = args;
    } else {
      print('❌ No apartment data received');
      Get.snackbar('Error', 'Apartment data is not available');
    }
  }

  int get totalDays =>
      (startDate.value != null && endDate.value != null)
          ? endDate.value!.difference(startDate.value!).inDays
          : 0;

  String get bookingType {
    if (totalDays >= 365) return "(Yearly)";
    if (totalDays >= 30) return "(Monthly)";
    return "(Daily)";
  }

  num get totalPrice {
    if (startDate.value == null || endDate.value == null || totalDays <= 0) {
      return 0;
    }

    final apt = apartment;
    final yearly = apt['yearly_price'] ?? 0;
    final monthly = apt['monthly_price'] ?? 0;
    final daily = apt['daily_price'] ?? 0;

    print(
      '💰 Calculating price: days=$totalDays, yearly=$yearly, monthly=$monthly, daily=$daily',
    );
    final diffDays = totalDays;

    final years = diffDays ~/ 365;
    final months = (diffDays % 365) ~/ 30;
    final days = (diffDays % 365) % 30;

    print("📌 Years=$years, Months=$months, Days=$days");

    return (years * yearly) + (months * monthly) + (days * daily);
  }

  Future<void> selectDate(bool isStartDate) async {
    print('📅 Selecting ${isStartDate ? 'start' : 'end'} date...');


  List<DateTime> bookedDates = [];
  try {
    final aptId = apartment['id'];
    if (aptId != null) {
      bookedDates = await ApiService.getBookedDates(aptId);
      print('📌 Found ${bookedDates.length} booked dates');
      for (var date in bookedDates) {
        print('   - ${DateFormat('yyyy-MM-dd').format(date)}');
      }
    }
  } catch (e) {
    print('⚠️ Could not fetch booked dates: $e');
  }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      selectableDayPredicate: (DateTime day) {
      final isBooked = bookedDates.any((bookedDate) => 
        day.year == bookedDate.year &&
        day.month == bookedDate.month &&
        day.day == bookedDate.day
    );
      final isBeforeToday = day.isBefore(DateTime.now().subtract(Duration(days: 1)));
      
      return !isBooked && !isBeforeToday;
    },
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
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
    print('✅ Date selected: $picked');
    if (isStartDate) {
      startDate.value = picked;
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    } else {
      if (startDate.value != null && picked.isAfter(startDate.value!)) {
        endDate.value = picked;
      } else {
        Get.snackbar('Error', 'End date must be after start date');
        return;
      }
    }
      update(); 
      print('📅 Start date: ${startDate.value}');
      print('📅 End date: ${endDate.value}');
      print('📅 Total days: $totalDays');
      print('💰 Total price: $totalPrice');
    } else {
      print('❌ Date selection cancelled');
    }
  }
  Future<void> confirmBooking() async {
    print('🔄 Confirming booking...');
    print('📅 Start: ${startDate.value}');
    print('📅 End: ${endDate.value}');
    print('💰 Price: $totalPrice');
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar('Error', 'Please select start and end dates');
      return;
    }
    if (totalDays <= 0) {
      Get.snackbar('Error', 'End date must be after start date');
      return;
    }
    if (apartment.isEmpty || apartment['id'] == null) {
      Get.snackbar('Error', 'Apartment data is not available');
      return;
    }
    isLoading.value = true;
    try {
      final formattedStart = DateFormat('yyyy-MM-dd').format(startDate.value!);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(endDate.value!);
      final apartmentId = apartment['id'];
      print('📤 Calling ApiService.createBooking...');
      final response = await ApiService.createBooking(
        apartmentId: apartmentId,
        startDate: formattedStart,
        endDate: formattedEnd,
      );
      if (response.statusCode == 201) {
        print('✅ Booking created successfully');
        Get.offNamed(
          '/booking-complete',
          arguments: {
            'startDate': startDate.value,
            'endDate': endDate.value,
            'apartmentName': apartment['name_of_apartment'],
          },
        );
        Get.snackbar('Success', 'Booking request sent to the owner');
      } else {
        final result = jsonDecode(response.body);
        final errorMessage = result['message'] ?? 'An error occurred';
        print('❌ Booking failed: $errorMessage');
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      print('❌ Booking error: $e');
      Get.snackbar('Error', 'Failed to connect to server');
    } finally {
      isLoading.value = false;
    }
  }
}