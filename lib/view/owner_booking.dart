import 'package:domus/controller/mybooking_controller.dart';
import 'package:domus/model/booking_model.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class OwnerBookingsPage extends GetView<BookingsController> {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        backgroundColor: const Color(0xFF2F6F74),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => controller.loadOwnerBookings(),
            icon: const Icon(Ionicons.refresh_outline),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ownerPendingBookings.isEmpty) {
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
                const Text(
                  'No booking requests',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.loadOwnerBookings(),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color:AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.ownerPendingBookings.length,
          itemBuilder: (context, index) {
            final booking = controller.ownerPendingBookings[index];
            return _buildBookingRequestCard(booking);
          },
        );
      }),
    );
  }

  Widget _buildBookingRequestCard(BookingModel booking) {
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Ionicons.business_outline,
                        size: 20,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        booking.apartmentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Ionicons.calendar_outline,
                  title: 'Period',
                  value: '${booking.formattedStartDate} - ${booking.formattedEndDate}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Ionicons.cash_outline,
                  title: 'Total Amount',
                  value: booking.formattedTotalPrice,
                  valueColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Ionicons.time_outline,
                  title: 'Request Date',
                  value: booking.createdAt != null
                      ? '${booking.createdAt!.day}/${booking.createdAt!.month}/${booking.createdAt!.year}'
                      : '-',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveBooking(booking.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(
                          Ionicons.checkmark_circle_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Approve',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectBooking(booking.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(
                          Ionicons.close_circle_outline,
                          size: 20,
                          color: Color(0xFFDC2626),
                        ),
                        label: const Text(
                          'Reject',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = const Color(0xFF64748B),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _approveBooking(int bookingId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirm Approval',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to approve this booking?',
          style: TextStyle(
            fontFamily: 'Nunito',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveOwnerBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text(
              'Yes, Approve',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(int bookingId) {
    TextEditingController reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reject Booking',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter a rejection reason (optional):',
              style: TextStyle(
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectOwnerBooking(
                bookingId,
                reason: reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(
              'Reject Booking',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}