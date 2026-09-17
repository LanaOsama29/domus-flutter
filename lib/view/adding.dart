import 'dart:io';
import 'package:domus/controller/adding_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Adding extends GetView<AddingApartmentController> {
  Adding({super.key});

  Widget sectionContainer({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget priceField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: inputDecoration(hint),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "Add Apartment",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            sectionContainer(
              title: "Apartment Name",
              child: TextFormField(
                controller: controller.nameController,
                decoration: inputDecoration("Enter apartment name"),
              ),
            ),

            // LOCATION
            sectionContainer(
              title: "Location",
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.provinceController,
                    decoration: inputDecoration("Province"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.cityController,
                    decoration: inputDecoration("City"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.addressController,
                    decoration: inputDecoration("Address"),
                  ),
                ],
              ),
            ),

            // DESCRIPTION
            sectionContainer(
              title: "Description",
              child: TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: inputDecoration("Enter description"),
              ),
            ),

            // PRICES
            sectionContainer(
              title: "Prices",
              child: Row(
                children: [
                  Expanded(
                    child: priceField(
                      "Daily Price",
                      controller.dailyPriceController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: priceField(
                      "Monthly Price",
                      controller.monthlyPriceController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: priceField(
                      "Yearly Price",
                      controller.yearlyPriceController,
                    ),
                  ),
                ],
              ),
            ),
            sectionContainer(
              title: "Images",
              child: Obx(
                () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.images.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    if (index == controller.images.length) {
                      return GestureDetector(
                        onTap: controller.pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 36,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(controller.images[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => controller.images.removeAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addApartment();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Add Apartment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
