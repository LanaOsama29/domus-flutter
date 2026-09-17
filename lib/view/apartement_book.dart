import 'dart:convert';

import 'package:domus/controller/ownerpost_controller.dart';
import 'package:domus/model/apartment_model.dart';
import 'package:domus/model/booking_model.dart';
import 'package:domus/services/api_service.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class ApartmentBookingsPage extends StatelessWidget {
  final ApartmentModel apartment;
  const ApartmentBookingsPage({super.key, required this.apartment});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerPostsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadApartmentBookings(apartment.id);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookings for ${apartment.name}",
          style: const TextStyle(fontSize: 18, fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () => controller.loadApartmentBookings(apartment.id),
          ),
        ],
      ),
      //backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        final isLoading = controller.isLoadingBookings[apartment.id] ?? true;
        final bookings = controller.apartmentBookings[apartment.id] ?? [];
        final stats = controller.getBookingStats(apartment.id);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Ionicons.calendar_outline,
                  size: 80,
                  color: Color(0xFFCBD5E1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'For: ${apartment.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total',
                    stats['total']?.toString() ?? '0',
                    Ionicons.calendar,
                  ),
                  _buildStatItem(
                    'Pending',
                    stats['pending']?.toString() ?? '0',
                    Ionicons.time_outline,
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildStatItem(
                    'Approved',
                    stats['approved']?.toString() ?? '0',
                    Ionicons.checkmark_circle,
                    color: const Color(0xFF10B981),
                  ),
                  _buildStatItem(
                    'Rejected',
                    stats['rejected']?.toString() ?? '0',
                    Ionicons.close_circle,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildBookingCard(booking);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon, {
    Color color = const Color(0xFF2F6F74),
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

 // في apartement_book.dart
Widget _buildBookingCard(BookingModel booking) {
  final isModified = booking.isModified ;
  final isPending = booking.status.toLowerCase() == 'pending';
  
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        // Header مع لون مختلف للحجوزات المعدلة
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isModified ? Colors.amber[50] : booking.statusColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    booking.statusText.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isModified ? Colors.amber[800] : booking.statusColor,
                    ),
                  ),
                  
                  // 🆕 علامة "MODIFIED" إذا كان معدلاً
                  if (isModified)
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'MODIFIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              // 🆕 أيقونة خاصة بالتعديلات
              if (isModified)
                const Icon(
                  Icons.edit_note,
                  color: Colors.amber,
                ),
            ],
          ),
        ),
        
        // Body
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الحجز
              _buildInfoRow('Renter', booking.renterName),
              _buildInfoRow('Dates', '${booking.formattedStartDate} - ${booking.formattedEndDate}'),
              _buildInfoRow('Amount', booking.formattedTotalPrice),
              
              // 🆕 تاريخ التعديل
              if (isModified && booking.modifiedAt != null)
                _buildInfoRow(
                  'Modified on',
                  booking.formattedModifiedAt,
                ),
              
              // 🆕 ملاحظات التعديل
              if (isModified && booking.modificationNotes != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Modification Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(booking.modificationNotes!),
                  ],
                ),
              
              const SizedBox(height: 20),
              
               if (isPending)
                if (isModified)
                  _buildModificationButtons(booking.id)
                else
                  _buildRegularButtons(booking.id),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _buildModificationButtons(int bookingId) {
  return Column(
    children: [
      const Text(
        'Review Modification Request',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => (bookingId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Approve Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _rejectModification(bookingId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
 /* void _approveModification(int bookingId) async {
  final controller = Get.find<OwnerPostsController>();

  Get.dialog(
    AlertDialog(
      title: const Text('Approve Modification'),
      content: const Text('Are you sure you want to approve these changes?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            
            // عرض loading
            Get.dialog(
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );
            
            try {
              print('✅ Approving modification for booking ID: $bookingId');
              
              // ⚠️ تأكد أن هذه الدالة موجودة في ApiService
              final response = await ApiService.approveModification(bookingId);
              
              Get.back(); // إغلاق loading
              
              print('📥 Approval response: ${response.statusCode}');
              print('📥 Response body: ${response.body}');
              
              if (response.statusCode == 200) {
                Get.snackbar(
                  '✅ Success',
                  'Modification approved successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
                );
                
                // تحديث البيانات
                await controller.loadApartmentBookings(apartment.id);
              } else {
                try {
                  final error = jsonDecode(response.body);
                  Get.snackbar(
                    '❌ Error',
                    error['message'] ?? 'Approval failed',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } catch (_) {
                  Get.snackbar(
                    '❌ Error',
                    'Approval failed (${response.statusCode})',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            } catch (e) {
              Get.back(); // إغلاق loading
              print('❌ Error approving modification: $e');
              Get.snackbar(
                '❌ Connection Error',
                'Failed to connect to server',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: const Text('Approve'),
        ),
      ],
    ),
  );
}
  */
  // أضف هذه الدالة في ملف apartement_book.dart
void _rejectModification(int bookingId) async {
  final controller = Get.find<OwnerPostsController>();
  
  // عرض dialog لكتابة سبب الرفض
  TextEditingController reasonController = TextEditingController();
  
  await Get.dialog(
    AlertDialog(
      title: const Text('Reject Modification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please provide a reason for rejecting the modification:'),
          const SizedBox(height: 15),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Reason for rejection...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (reasonController.text.trim().isEmpty) {
              Get.snackbar('Error', 'Please enter a reason');
              return;
            }
            
            Get.back(); // إغلاق الـdialog
            
            try {
              // استدعاء API لرفض التعديل
              final response = await ApiService.rejectModification(
                bookingId,
                reason: reasonController.text,
              );
              
              if (response.statusCode == 200) {
                Get.snackbar(
                  '✅ Rejected',
                  'Modification rejected successfully',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                // تحديث القائمة
                await controller.loadApartmentBookings(apartment.id);
              } else {
                final error = jsonDecode(response.body);
                Get.snackbar(
                  'Error',
                  error['message'] ?? 'Rejection failed',
                );
              }
            } catch (e) {
              Get.snackbar('Error', 'Connection failed: $e');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
// في apartement_book.dart
Widget _buildRegularButtons(int bookingId) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _approveBooking(bookingId),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Approve'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _rejectBooking(bookingId),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFEF4444)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(
            Icons.close,
            size: 18,
            color: Color(0xFFEF4444),
          ),
          label: const Text(
            'Reject',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ),
      ),
    ],
  );
}
  

  void _approveBooking(int bookingId) async {
    final controller = Get.find<OwnerPostsController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Approval'),
        content: const Text('Are you sure you want to approve this booking?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                print('✅ Attempting to approve booking ID: $bookingId');
                final response = await ApiService.approveBooking(bookingId);
                print('📥 Approval response: ${response.statusCode}');
                print('📥 Response content: ${response.body}');
                if (response.statusCode == 200) {
                  Get.snackbar(
                    'Success',
                    'Booking approved successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  print('🔄 Reloading bookings for apartment ${apartment.id}');
                  await controller.loadApartmentBookings(apartment.id);
                } else {
                  final body = jsonDecode(response.body);
                  final errorMessage =
                      body['message'] ?? 'Failed to approve booking';
                  Get.snackbar('Error', errorMessage);
                }
              } catch (e) {
                print('❌ Error approving booking: $e');
                Get.snackbar(
                  'Error',
                  'Failed to connect to server: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Yes, Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(int bookingId) async {
    final controller = Get.find<OwnerPostsController>(); 

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Rejection'),
        content: const Text('Are you sure you want to reject this booking?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                print('❌ Attempting to reject booking ID: $bookingId');
                final response = await ApiService.rejectBooking(bookingId);

                print('📥 Rejection response: ${response.statusCode}');
                print('📥 Response content: ${response.body}');

                if (response.statusCode == 200) {
                  Get.snackbar(
                    'Success',
                    'Booking rejected successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  print('🔄 Reloading bookings for apartment ${apartment.id}');
                  await controller.loadApartmentBookings(apartment.id);
                } else {
                  final body = jsonDecode(response.body);
                  final errorMessage =
                      body['message'] ?? 'Failed to reject booking';
                  Get.snackbar('Error', errorMessage);
                }
              } catch (e) {
                print('❌ Error rejecting booking: $e');
                Get.snackbar(
                  'Error',
                  'Failed to connect to server: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Yes, Reject'),
          ),
        ],
      ),
    );
  }
}
