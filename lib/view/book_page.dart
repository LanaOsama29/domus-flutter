import 'package:domus/controller/booking_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class BookNowPage extends GetView<BookingController> {
  const BookNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApartmentCard(),
                  const SizedBox(height: 30),
                  _buildDateSelection(),
                  const SizedBox(height: 30),
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: const Center(
        child: Text(
          "Booking Confirmation",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildApartmentCard() {
    return GetBuilder<BookingController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Ionicons.business_outline,
                  size: 30,
                  color: Color(0xFFF4A431),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.apartment['name_of_apartment'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${controller.apartment['province'] ?? ''} - ${controller.apartment['city'] ?? ''}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          "Select Period",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _dateBox("Start Date", true)),
            const SizedBox(width: 12),
            Expanded(child: _dateBox("End Date", false)),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String title, bool isStart) {
    return GetBuilder<BookingController>(
      builder: (controller) {
        final date =
            isStart ? controller.startDate.value : controller.endDate.value;
        print('🔄 Rebuilding date box: $title = $date');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => controller.selectDate(isStart),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date == null
                          ? "Select"
                          : DateFormat('yyyy-MM-dd').format(date),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const Icon(
                      Ionicons.calendar_outline,
                      size: 18,
                      color: Color(0xFF2F6F74),
                    ),
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
    return GetBuilder<BookingController>(
      builder: (controller) {
        print('🔄 Rebuilding price summary');
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _summaryRow(
                "Booking Type",
                controller.startDate.value == null
                    ? "---"
                    : controller.bookingType,
                isValueBold: true,
              ),
              const Divider(height: 30),
              _summaryRow("Total Duration", "${controller.totalDays} Days"),
              const Divider(height: 30),
              _summaryRow(
                "Total Amount",
                "${NumberFormat('#,###').format(controller.totalPrice)} \$",
                isPrimary: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isPrimary = false,
    bool isValueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight:
                (isPrimary || isValueBold) ? FontWeight.bold : FontWeight.w500,
            fontSize: isPrimary ? 18 : 14,
            color: isPrimary ? const Color(0xFF2F6F74) : Colors.black87,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return GetBuilder<BookingController>(
      builder: (controller) {
        print('🔄 Rebuilding bottom action');
        final isEnabled =
            controller.startDate.value != null &&
            controller.endDate.value != null &&
            !controller.isLoading.value &&
            controller.totalDays > 0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6F74),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: isEnabled ? controller.confirmBooking : null,
              child:
                  controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        "Confirm Booking Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}
