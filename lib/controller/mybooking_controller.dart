import 'dart:async';
import 'dart:convert';
import 'package:domus/controller/edit_booking_controller.dart';
import 'package:domus/model/booking_model.dart';
import 'package:domus/services/api_service.dart';
import 'package:domus/view/edit_booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BookingsController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isOwner = false.obs;
  final userRole = ''.obs;
  final pendingBookings = <BookingModel>[].obs; 
  final approvedBookings = <BookingModel>[].obs; 
  final activeBookings = <BookingModel>[].obs; 
  final completedBookings = <BookingModel>[].obs; // منتهية
  final cancelledBookings = <BookingModel>[].obs; // ملغية
  final rejectedBookings = <BookingModel>[].obs; // مرفوضة
  final ownerPendingBookings = <BookingModel>[].obs;
  final box = GetStorage();
  Timer? _refreshTimer;
  bool _hasInitialized = false;

  // Storage key for cancelled bookings
  static const String _cancelledBookingsKey = 'cancelled_bookings';
  @override
  void onInit() {
    super.onInit();
    print('🔄 BookingsController initialized');
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializeController();
    }
    ever(isLoading, (loading) {
      if (!loading) {
        // إذا انتهى loading، يمكننا تحديث العرض
        update();
      }
    });
  }

  Future<void> _initializeController() async {
    await Future.delayed(Duration(milliseconds: 800));
    await _checkUserRole();
    _loadCancelledBookingsFromStorage();
    _setupAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _autoRefreshBookings();
    });
  }

  /*Future<void> _moveToCancelledLocally(int bookingId) async {
    // البحث في جميع القوائم
    final allBookings = getAllBookings();
    final bookingIndex = allBookings.indexWhere((b) => b.id == bookingId);

    if (bookingIndex != -1) {
      final booking = allBookings[bookingIndex];

      // إزالته من القوائم الحالية
      pendingBookings.removeWhere((b) => b.id == bookingId);
      approvedBookings.removeWhere((b) => b.id == bookingId);
      activeBookings.removeWhere((b) => b.id == bookingId);

      // إضافته لـcancelled مع تحديث الحالة
      final cancelledBooking = BookingModel(
        id: booking.id,
        apartmentId: booking.apartmentId,
        apartmentName: booking.apartmentName,
        apartmentImage: booking.apartmentImage,
        startDate: booking.startDate,
        endDate: booking.endDate,
        totalPrice: booking.totalPrice,
        status: 'cancelled', // ⬅️ تغيير الحالة
        paymentStatus: booking.paymentStatus,
        rejectionReason: booking.rejectionReason,
        approvedAt: booking.approvedAt,
        createdAt: booking.createdAt,
        renterName: booking.renterName,
      );

      cancelledBookings.insert(0, cancelledBooking);
      update(); // تحديث الـUI
    }
  }*/

  void _autoRefreshBookings() {
    final token = box.read('token');
    if (token == null) return;
    if (!isLoading.value && !isOwner.value) {
      print('🔄 Auto-refreshing bookings...');
      loadMyBookings(silent: true);
    }
  }

  Future<void> _checkUserRole() async {
    final token = box.read('token');
    if (token == null) {
      print('🚫 User not logged in');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    try {
      final userData = box.read('userData');

      if (userData != null) {
        final role = userData['role']?.toString().toLowerCase() ?? '';
        userRole.value = role;
        isOwner.value = role == 'owner' || role == 'landlord' || role == 'مالك';

        print('👤 User role: $role - isOwner: ${isOwner.value}');
        if (!isOwner.value) {
          await loadMyBookings();
        }
      } else {
        print('⚠️ No user data, assuming renter');
        isOwner.value = false;
        await loadMyBookings();
      }
    } catch (e) {
      print('❌ Error checking user role: $e');
      isOwner.value = false;
      await loadMyBookings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyBookings({bool silent = false, bool force = false}) async {
    final token = box.read('token');
    if (token == null) {
      print('🚫 User not logged in, skipping bookings load');
      return;
    }
    if (isOwner.value && !force) {
      print('ℹ️ User is owner, skipping renter bookings');
      return;
    }
    if (isLoading.value && !force) {
      print('⏸️ Already loading, skipping...');
      return;
    }

    if (!silent) isLoading.value = true;
    hasError.value = false;

    print('🔄 Loading my bookings...');

    try {
      final response = await ApiService.getMyBookings();

      if (response.containsKey('bookings')) {
        final Map<String, dynamic> bookings = response['bookings'];
        pendingBookings.clear();
        approvedBookings.clear();
        activeBookings.clear();
        completedBookings.clear();
        cancelledBookings.clear();
        rejectedBookings.clear();
        final List<BookingModel> allBookings = [];
        _parseBookingsList(bookings['pending'], allBookings);
        _parseBookingsList(bookings['approved'], allBookings);
        _parseBookingsList(bookings['canceled'], allBookings);
        _parseBookingsList(bookings['rejected'], allBookings);
        _categorizeBookings(allBookings);

        // Load cancelled bookings from storage to preserve locally cancelled bookings
        _loadCancelledBookingsFromStorage();

        print('✅ Bookings updated successfully');
        print('   - Pending: ${pendingBookings.length}');
        print('   - Approved (not started): ${approvedBookings.length}');
        print('   - Active: ${activeBookings.length}');
        print('   - Completed: ${completedBookings.length}');
        print('   - Cancelled: ${cancelledBookings.length}');
        print('   - Rejected: ${rejectedBookings.length}');

        update();
      }
    } catch (e) {
      print('❌ Error loading bookings: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      if (!silent) {
        Get.snackbar('Error', 'Failed to load bookings');
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  void _parseBookingsList(List<dynamic>? data, List<BookingModel> targetList) {
    if (data == null || data.isEmpty) return;

    for (var item in data) {
      try {
        targetList.add(BookingModel.fromJson(item));
      } catch (e) {
        print('⚠️ Error converting booking data: $e');
      }
    }
  }

  void _categorizeBookings(List<BookingModel> allBookings) {
    final now = DateTime.now();

    for (var booking in allBookings) {
      try {
        final startDate = _parseDate(booking.startDate);
        final endDate = _parseDate(booking.endDate);

        if (startDate == null || endDate == null) {
          print('⚠️ Error parsing booking dates ${booking.id}');
          continue;
        }

        if (booking.status.toLowerCase() == 'rejected') {
          rejectedBookings.add(booking);
        } else if (booking.status.toLowerCase() == 'canceled') {
          cancelledBookings.add(booking);
        } else if (booking.status.toLowerCase() == 'pending') {
          pendingBookings.add(booking);
        } else if (booking.status.toLowerCase() == 'approved') {
          if (endDate.isBefore(now)) {
            completedBookings.add(booking);
          } else if (startDate.isAfter(now)) {
            approvedBookings.add(booking);
          } else {
            activeBookings.add(booking);
          }
        }
      } catch (e) {
        print('⚠️ Error categorizing booking ${booking.id}: $e');
      }
    }
    _sortBookingsByDate();
  }

  DateTime? _parseDate(String dateString) {
    try {
      final cleanDate = dateString.split(' ').first;

      if (cleanDate.contains('-')) {
        final parts = cleanDate.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } else if (cleanDate.contains('/')) {
        final parts = cleanDate.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      return DateTime.parse(cleanDate);
    } catch (e) {
      print('⚠️ Error parsing date: $dateString - $e');
      return null;
    }
  }

  void _sortBookingsByDate() {
    int compareDates(BookingModel a, BookingModel b) {
      final dateA = _parseDate(a.startDate);
      final dateB = _parseDate(b.startDate);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA); // Newest first
    }

    pendingBookings.sort(compareDates);
    approvedBookings.sort(compareDates);
    activeBookings.sort(compareDates);
    cancelledBookings.sort(compareDates);
    rejectedBookings.sort(compareDates);
    completedBookings.sort((a, b) {
      final dateA = _parseDate(a.endDate);
      final dateB = _parseDate(b.endDate);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });
  }

  Future<void> refreshBookings() async {
    if (isOwner.value) {
      print('ℹ️ User is an owner, bookings are not refreshed');
      return;
    }
    await loadMyBookings();
  }

  Future<void> refreshRoleAndBookings() async {
    print('🔄 Refreshing role and bookings after login...');
    await _checkUserRole();
    update(); // Force UI update
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      print('🗑️ Cancelling booking ID: $bookingId');

      final response = await ApiService.cancelBooking(bookingId);

      if (response.statusCode == 200) {
        Get.snackbar(
          '✅ Success',
          'Booking cancelled successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // ✅ تحديث فوري للقوائم
        await _updateBookingAfterCancellation(bookingId);
      } else {
        final result = jsonDecode(response.body);
        Get.snackbar(
          '❌ Error',
          result['message'] ?? 'Cancellation failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to cancel booking',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🆕 دالة لتحديث الحجز بعد الإلغاء
  Future<void> _updateBookingAfterCancellation(int bookingId) async {
    print('🔄 Updating booking lists after cancellation...');

    // البحث عن الحجز في جميع القوائم
    BookingModel? cancelledBooking;

    // البحث في pending
    final pendingIndex = pendingBookings.indexWhere((b) => b.id == bookingId);
    if (pendingIndex != -1) {
      cancelledBooking = pendingBookings[pendingIndex];
      pendingBookings.removeAt(pendingIndex);
    }

    // البحث في approved (إذا كان approved)
    final approvedIndex = approvedBookings.indexWhere((b) => b.id == bookingId);
    if (approvedIndex != -1) {
      cancelledBooking = approvedBookings[approvedIndex];
      approvedBookings.removeAt(approvedIndex);
    }

    // البحث في active (نادراً)
    final activeIndex = activeBookings.indexWhere((b) => b.id == bookingId);
    if (activeIndex != -1) {
      cancelledBooking = activeBookings[activeIndex];
      activeBookings.removeAt(activeIndex);
    }
    if (cancelledBooking != null) {
      final updatedBooking = BookingModel(
        id: cancelledBooking.id,
        apartmentId: cancelledBooking.apartmentId,
        apartmentName: cancelledBooking.apartmentName,
        apartmentImage: cancelledBooking.apartmentImage,
        startDate: cancelledBooking.startDate,
        endDate: cancelledBooking.endDate,
        totalPrice: cancelledBooking.totalPrice,
        status: 'cancelled', 
        paymentStatus: cancelledBooking.paymentStatus,
        rejectionReason: cancelledBooking.rejectionReason,
        approvedAt: cancelledBooking.approvedAt,
        createdAt: cancelledBooking.createdAt,
        renterName: cancelledBooking.renterName,
      );
      cancelledBookings.insert(0, updatedBooking); 
      print('✅ Booking moved to cancelled tab');
      _saveCancelledBookingsToStorage();
      update(); 
    }
  }

  Future<void> editBooking(BookingModel booking) async {
    Get.to(
      () => const EditBookingPage(),
      binding: BindingsBuilder(() {
        Get.put(EditBookingController());
      }),
      arguments: booking,
    );
  }

  Future<void> loadOwnerBookings() async {
    try {
      print('🔄 Fetching owner bookings...');
      final response = await ApiService.getOwnerBookings();

      if (response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        ownerPendingBookings.clear();

        for (var booking in data) {
          try {
            ownerPendingBookings.add(BookingModel.fromJson(booking));
          } catch (e) {
            print('⚠️ Error converting booking data: $e');
          }
        }

        print('✅ Owner bookings: ${ownerPendingBookings.length}');
      }
    } catch (e) {
      print('❌ Error fetching owner bookings: $e');
      Get.snackbar('Error', 'Failed to fetch owner bookings');
    }
  }

  Future<void> approveOwnerBooking(int bookingId) async {
    try {
      final response = await ApiService.approveBooking(bookingId);

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Booking approved');
        await loadOwnerBookings();
      } else {
        final result = jsonDecode(response.body);
        Get.snackbar('Error', result['message'] ?? 'Approval failed');
      }
    } catch (e) {
      print('❌ Error approving booking: $e');
      Get.snackbar('Error', 'Failed to approve booking');
    }
  }

  Future<void> rejectOwnerBooking(int bookingId, {String? reason}) async {
    try {
      final response = await ApiService.rejectBooking(
        bookingId,
        reason: reason,
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Booking rejected');
        await loadOwnerBookings();
      } else {
        final result = jsonDecode(response.body);
        Get.snackbar('Error', result['message'] ?? 'Rejection failed');
      }
    } catch (e) {
      print('❌ Error rejecting booking: $e');
      Get.snackbar('Error', 'Failed to reject booking');
    }
  }

  // Save cancelled bookings to storage
  void _saveCancelledBookingsToStorage() {
    try {
      final cancelledBookingsJson =
          cancelledBookings.map((booking) => booking.toJson()).toList();
      box.write(_cancelledBookingsKey, cancelledBookingsJson);
      print(
        '💾 Saved ${cancelledBookings.length} cancelled bookings to storage',
      );
    } catch (e) {
      print('❌ Error saving cancelled bookings to storage: $e');
    }
  }

  // Load cancelled bookings from storage
  void _loadCancelledBookingsFromStorage() {
    try {
      final storedData = box.read(_cancelledBookingsKey);
      if (storedData != null && storedData is List) {
        for (var item in storedData) {
          try {
            final booking = BookingModel.fromJson(item);
            // Check if booking already exists to avoid duplicates
            final existingIndex = cancelledBookings.indexWhere(
              (b) => b.id == booking.id,
            );
            if (existingIndex == -1) {
              cancelledBookings.add(booking);
            }
          } catch (e) {
            print('⚠️ Error parsing stored booking: $e');
          }
        }
        print(
          '📥 Loaded ${cancelledBookings.length} cancelled bookings from storage',
        );
      }
    } catch (e) {
      print('❌ Error loading cancelled bookings from storage: $e');
    }
  }

  // Clear cancelled bookings from storage (for account deletion)
  void clearCancelledBookingsFromStorage() {
    box.remove(_cancelledBookingsKey);
    cancelledBookings.clear();
    print('🗑️ Cleared cancelled bookings from storage');
  }

  List<BookingModel> getAllBookings() {
    return [
      ...pendingBookings,
      ...approvedBookings,
      ...activeBookings,
      ...completedBookings,
      ...cancelledBookings,
      ...rejectedBookings,
    ];
  }
}
