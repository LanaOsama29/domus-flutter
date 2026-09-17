import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:domus/controller/edit_booking_controller.dart';

class EditBookingPage extends GetView<EditBookingController> {
  const EditBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingInfo(),
            const SizedBox(height: 30),
            _buildDateSelection(),
            const SizedBox(height: 30),
            _buildPriceSummary(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBookingInfo() {
    return GetBuilder<EditBookingController>(
      builder: (controller) {
        final booking = controller.booking.value;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking?.apartmentName ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current: ${booking?.formattedStartDate} - ${booking?.formattedEndDate}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Amount: ${booking?.formattedTotalPrice}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select New Dates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _dateBox('Start Date', true)),
            const SizedBox(width: 12),
            Expanded(child: _dateBox('End Date', false)),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String title, bool isStart) {
    return GetBuilder<EditBookingController>(
      builder: (controller) {
        final date = isStart ? controller.startDate.value : controller.endDate.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => controller.selectDate(isStart),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date == null ? 'Select' : DateFormat('yyyy-MM-dd').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Ionicons.calendar_outline, color: Color(0xFF2F6F74)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceSummary() {
    return GetBuilder<EditBookingController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow('Total Days', '${controller.totalDays} days'),
                const Divider(),
                _summaryRow('Total Amount', '\$${controller.totalPrice.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return GetBuilder<EditBookingController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.updateBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6F74),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Booking', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}