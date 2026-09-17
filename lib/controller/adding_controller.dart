import 'package:domus/controller/explore_controller.dart';
import 'package:domus/controller/ownerpost_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddingApartmentController extends GetxController {
  final nameController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final dailyPriceController = TextEditingController();
  final monthlyPriceController = TextEditingController();
  final yearlyPriceController = TextEditingController();

  final images = <XFile>[].obs;
  final ImagePicker picker = ImagePicker();
  final isLoading = false.obs;

  Future<void> pickImages() async {
    try {
      final List<XFile>? selectedImages = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (selectedImages != null && selectedImages.isNotEmpty) {
        if (images.length + selectedImages.length > 10) {
          Get.snackbar(
            "Limit Exceeded",
            "You can upload maximum 10 images",
            backgroundColor: Colors.orange,
          );
          return;
        }

        images.addAll(selectedImages);
        Get.snackbar(
          "Success",
          "Added ${selectedImages.length} image(s)",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick images: ${e.toString()}");
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Apartment name is required");
      return false;
    }

    if (provinceController.text.isEmpty) {
      Get.snackbar("Error", "Province is required");
      return false;
    }

    if (cityController.text.isEmpty) {
      Get.snackbar("Error", "City is required");
      return false;
    }
    if (images.isEmpty) {
      Get.snackbar("Error", "At least one image is required");
      return false;
    }
    return true;
  }
  Future<void> addApartment() async {
    if (!_validateForm()) return;

    isLoading.value = true;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiService.addApartment(
        name: nameController.text,
        province: provinceController.text,
        city: cityController.text,
        address: addressController.text,
        description: descriptionController.text,
        dailyPrice: dailyPriceController.text.isNotEmpty
            ? double.tryParse(dailyPriceController.text)
            : null,
        monthlyPrice: monthlyPriceController.text.isNotEmpty
            ? double.tryParse(monthlyPriceController.text)
            : null,
        yearlyPrice: yearlyPriceController.text.isNotEmpty
            ? double.tryParse(yearlyPriceController.text)
            : null,
        images: images.toList(),
      );
      Get.back();
      print("Add Apartment Response: ${response.statusCode}");
      print("Add Apartment Body: ${response.body}");
      if (response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Apartment added successfully",
          backgroundColor: AppColors.button,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        try {

          if (Get.isRegistered<OwnerPostsController>()) {
            final postsController = Get.find<OwnerPostsController>();
            postsController.refreshPosts(); 
          }
        } catch (e) {
          print("Error updating posts: $e");
        }
        try {
          if (Get.isRegistered<ExploreController>()) {
            final exploreController = Get.find<ExploreController>();
            await exploreController.fetchApartments();
          }
        } catch (e) {
          print("Error updating explore: $e");
        }
        GetStorage().remove('apartments_cache');
        clearForm();
        Get.back(result: true);
        
      } else {
        final error = response.body;
        Get.snackbar(
          "Error",
          "Failed to add apartment: $error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Add apartment error: $e");
    } finally {
      isLoading.value = false;
    }
  }
  void clearForm() {
    nameController.clear();
    provinceController.clear();
    cityController.clear();
    addressController.clear();
    descriptionController.clear();
    dailyPriceController.clear();
    monthlyPriceController.clear();
    yearlyPriceController.clear();
    images.clear();
  }
  @override
  void onClose() {
    nameController.dispose();
    provinceController.dispose();
    cityController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    dailyPriceController.dispose();
    monthlyPriceController.dispose();
    yearlyPriceController.dispose();
    super.onClose();
  }
}
