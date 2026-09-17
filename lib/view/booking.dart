import 'package:domus/controller/mybooking_controller.dart';
import 'package:domus/model/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:domus/view/component/color.dart';

class MyBookingsPage extends GetView<BookingsController> {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final box = GetStorage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = box.read('token');
      if (token != null) {
        Future.delayed(Duration(milliseconds: 300), () {
          controller.loadMyBookings();
        });
      }
    });
    return Obx(() {
      final token = box.read('token');
      if (token == null) {
        return Scaffold(
          // backgroundColor: Color(0xFFF8FAFC),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 80, color: Color(0xFF94A3B8)),
                SizedBox(height: 20),
                Text(
                  'Please login to view your bookings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (controller.isLoading.value && controller.isOwner.value == false) {
        return const Scaffold(
          // backgroundColor: Color(0xFFF8FAFC),
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.isOwner.value) {
        return Scaffold(
          //  backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Container(
                height: h * 0.20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: h * 0.05),
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: h * 0.02),
                  ],
                ),
              ),
              Expanded(child: _buildOwnerMessage()),
            ],
          ),
        );
      }
      return DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          // backgroundColor: Colors.white,
          body: Column(
            children: [
              Container(
                height: h * 0.20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: h * 0.05),
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: h * 0.03),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF6B7280),
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Cancelled'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshBookings(),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.hasError.value) {
                      return _buildErrorWidget();
                    }
                    return TabBarView(
                      children: [
                        _buildBookingsList(
                          controller.activeBookings,
                          emptyMessage: 'No active bookings',
                          showCancelOption: false,
                        ),
                        _buildBookingsList(
                          [
                            ...controller.pendingBookings,
                            ...controller.approvedBookings,
                          ],
                          emptyMessage: 'No upcoming bookings',
                          showCancelOption: true,
                        ),
                        _buildBookingsList(
                          controller.cancelledBookings,
                          emptyMessage: 'No cancelled bookings',
                          showCancelOption: false,
                        ),
                        _buildBookingsList(
                          [
                            ...controller.completedBookings,
                            ...controller.rejectedBookings,
                          ],
                          emptyMessage: 'No completed bookings',
                          showCancelOption: false,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Ionicons.sad_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Error loading data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => controller.refreshBookings(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Ionicons.business_outline,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F6F74),
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This page is for renters to view their bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    List<BookingModel> bookings, {
    required String emptyMessage,
    bool showCancelOption = false,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Ionicons.calendar_outline,
              size: 70,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, showCancelOption);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, bool showCancelOption) {
    final startDate = _parseDate(booking.startDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              color: const Color(0xFFE2E8F0),
              image:
                  booking.apartmentImage.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(booking.apartmentImage),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                booking.apartmentImage.isEmpty
                    ? const Center(
                      child: Icon(
                        Ionicons.business_outline,
                        size: 60,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                    : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.apartmentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Ionicons.calendar_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${booking.formattedStartDate} - ${booking.formattedEndDate}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Ionicons.cash_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.formattedTotalPrice,
                      style: const TextStyle(
                        color: Color(0xFF2F6F74),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: booking.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.statusText,
                        style: TextStyle(
                          color: booking.statusColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                    if (showCancelOption &&
                        (booking.status.toLowerCase() == 'pending' ||
                            booking.status.toLowerCase() == 'approved'))
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.editBooking(booking),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons
                                        .edit_outlined, // يمكنك استخدام Ionicons.create_outline
                                    size: 14,
                                    color: Color(0xFF0369A1),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Color(0xFF0369A1),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          _buildCancelButton(booking, startDate),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // في booking.dart - دالة _buildCancelButton
  Widget _buildCancelButton(BookingModel booking, DateTime? startDate) {
    final now = DateTime.now();

    // ✅ السماح بالإلغاء إذا:
    // 1. pending (أصلاً)
    // 2. approved ولم يبدأ بعد
    final isPending = booking.status.toLowerCase() == 'pending';
    final isApprovedNotStarted =
        booking.status.toLowerCase() == 'approved' &&
        startDate != null &&
        startDate.isAfter(now);

    // ✅ إضافة الحالة approved
    final isCancellable = isPending || isApprovedNotStarted;

    if (!isCancellable) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _showCancelDialog(booking.id, booking.status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFDC2626)),
            SizedBox(width: 4),
            Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // في نفس الملف
  /*Widget _buildEditButton(BookingModel booking, DateTime? startDate) {
  final now = DateTime.now();
  
  // ✅ السماح بالتعديل إذا:
  // 1. pending (أصلاً)
  // 2. approved ولم يبدأ بعد
  final isPending = booking.status.toLowerCase() == 'pending';
  final isApprovedNotStarted = booking.status.toLowerCase() == 'approved' &&
      startDate != null &&
      startDate.isAfter(now);
  
  final isEditable = isPending || isApprovedNotStarted;

  if (!isEditable) {
    return const SizedBox.shrink();
  }
  
  return InkWell(
    onTap: () => controller.editBooking(booking),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: Color(0xFF0369A1),
          ),
          SizedBox(width: 4),
          Text(
            'Edit',
            style: TextStyle(
              color: Color(0xFF0369A1),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}*/
  void _showCancelDialog(int bookingId, String status) {
    final isApproved = status.toLowerCase() == 'approved';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isApproved ? 'Cancel Approved Booking' : 'Cancel Booking',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApproved
                  ? 'Cancelling an approved booking will refund your payment.'
                  : 'Are you sure you want to cancel this booking?',
              style: const TextStyle(fontFamily: 'Nunito'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Back',
              style: TextStyle(fontFamily: 'Nunito', color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // إغلاق الـdialog

              // استدعاء دالة الإلغاء
              final controller = Get.find<BookingsController>();
              controller.cancelBooking(bookingId);

              // ✅ يمكنك أيضًا إضافة هذا لإظهار الحجز في تبويب cancelled
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // إذا كنت في صفحة Bookings، تأكد من التحديث
                if (Get.currentRoute.contains('/my-bookings')) {
                  controller.refreshBookings();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String dateString) {
    try {
      final cleanDate = dateString.split(' ').first;
      return DateTime.parse(cleanDate);
    } catch (_) {
      return null;
    }
  }
}
