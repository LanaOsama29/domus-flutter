import 'package:domus/model/apartment_model.dart';
import 'package:domus/services/api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ExploreController extends GetxController {
  final apartments = <ApartmentModel>[].obs;
  final isLoading = true.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchApartments();
  }

  Future<void> fetchApartments() async {
    try {
      isLoading.value = true;
      print("📡 Fetching apartments...");

      final result = await ApiService.getApartments();
      print("✅ Result received: ${result.length} items");

      final list = <ApartmentModel>[];
      for (var item in result) {
        try {
          final model = ApartmentModel.fromJson(item);
          list.add(model);
          print("✅ Added model: ${model.name}, Price: ${model.monthlyPrice}");
        } catch (e) {
          print("❌ Error converting item: $e");
          print("❌ Item data: $item");
        }
      }

      print("✅ Total models: ${list.length}");
      apartments.assignAll(list);

      box.write('apartments_cache', result);
    } catch (e) {
      print("❌ API ERROR => $e");
      print("📦 Falling back to cache...");

      if (box.hasData('apartments_cache')) {
        final cached = box.read('apartments_cache') as List;
        print("📦 Cache found: ${cached.length} items");

        final list =
            cached
                .map((e) {
                  try {
                    return ApartmentModel.fromJson(e);
                  } catch (err) {
                    print("❌ Cache conversion error: $err");
                    return null;
                  }
                })
                .where((e) => e != null)
                .cast<ApartmentModel>()
                .toList();

        apartments.assignAll(list);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
