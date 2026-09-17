import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domus/services/api_service.dart';

class FilteringController extends GetxController {
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000000.0.obs;

  @override
  void onClose() {
    provinceController.dispose();
    cityController.dispose();
    super.onClose();
  }

  Future<void> searchProperties() async {
    try {
      isLoading.value = true;
      searchResults.clear();

      print('🔍 Starting search with the following information:');
      print('   - Province: ${provinceController.text}');
      print('   - City: ${cityController.text}');
      print('   - Price: ${minPrice.value} - ${maxPrice.value}');

      final response = await ApiService.searchApartments(
        province: provinceController.text,
        city: cityController.text,
        minPrice: minPrice.value > 0 ? minPrice.value : null,
        maxPrice: maxPrice.value > 0 ? maxPrice.value : null,
      );

      print('✅ API response received');
      if (response.containsKey('data')) {
        if (response['data'] is List) {
          searchResults.value = response['data'];
        } else if (response['data'] is Map &&
            response['data']['data'] != null) {
          searchResults.value = response['data']['data'];
        }

        print('✅ Number of results: ${searchResults.length}');
      }
    } catch (e) {
      print('❌ Search error: $e');
      Get.snackbar(
        'Search Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
