import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class BookingCompletePage extends StatelessWidget {
  const BookingCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final startDate = args['startDate'];
    final endDate = args['endDate'];

    return Scaffold(
      //  backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Ionicons.checkmark_circle,
              size: 120,
              color: AppColors.primary,
            ),
            const SizedBox(height: 40),

            // Title
            const Text(
              'Booking Request Sent!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A7074),
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              'Your request will be reviewed by the owner\nand you will receive confirmation soon',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontFamily: 'Nunito',
              ),
            ),

            if (startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'From ${_formatDate(startDate)} to ${_formatDate(endDate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),

            const SizedBox(height: 50),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.until((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7074),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF2FF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Booking Details',
                      style: TextStyle(
                        color: AppColors.primary,
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
