import 'package:domus/model/apartment_model.dart';
import 'package:domus/model/booking_model.dart';
import 'package:domus/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerPostsController extends GetxController {
  final isLoading = false.obs;
  final posts = <ApartmentModel>[].obs;
  final apartmentBookings = <int, List<BookingModel>>{}.obs;
  final isLoadingBookings = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final apartments = await ApiService.getOwnerApartments();
      posts.assignAll(apartments);
      for (var apt in apartments) {
        apartmentBookings[apt.id] = [];
        isLoadingBookings[apt.id] = false;
      }

      print("✅ Loaded ${posts.length} apartments");
    } catch (e) {
      print("❌ Error loading posts: $e");
      Get.snackbar('Error', 'Failed to load apartments');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadApartmentBookings(int apartmentId) async {
    isLoadingBookings[apartmentId] = true;
    apartmentBookings[apartmentId] = [];

    try {
      print("📥 Loading bookings for apartment $apartmentId");

      final bookings = await ApiService.getApartmentBookings(apartmentId);
      apartmentBookings[apartmentId] = bookings;

      print("✅ Loaded ${bookings.length} bookings for apartment $apartmentId");
      for (var booking in bookings.take(2)) {
        print(
          '📋 Booking: ${booking.id} - ${booking.status} - ${booking.formattedStartDate}',
        );
      }
    } catch (e) {
      print("❌ Error loading bookings: $e");
      Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoadingBookings[apartmentId] = false;
    }
  }
  Map<String, int> getBookingStats(int apartmentId) {
    final bookings = apartmentBookings[apartmentId] ?? [];

    return {
      'total': bookings.length,
      'pending':
          bookings.where((b) => b.status.toLowerCase() == 'pending').length,
      'approved':
          bookings.where((b) => b.status.toLowerCase() == 'approved').length,
      'rejected':
          bookings.where((b) => b.status.toLowerCase() == 'rejected').length,
    };
  }


  Future<void> refreshPosts() async {
    print("🔄 Refreshing owner posts...");
    
    try {
      final apartments = await ApiService.getOwnerApartments();
      print("📥 Received ${apartments.length} apartments from API");
      
      if (apartments.isNotEmpty) {
        print("✅ First apartment: ${apartments.first.name}");
      }
      posts.assignAll(apartments);
      update();
      
      Get.snackbar(
        "Success",
        "Posts refreshed",
        backgroundColor: Colors.green,
      );
      
    } catch (e) {
      print("❌ Error in refreshPosts: $e");
      Get.snackbar(
        "Error",
        "Failed to refresh posts: $e",
        backgroundColor: Colors.red,
      );
    }
  }
}

