import 'dart:async';
import 'package:domus/model/apartment_model.dart';
import 'package:domus/services/api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FavoriteController extends GetxController {
  final favoriteApartments = <ApartmentModel>[].obs;
  final isLoading = true.obs;
  final favoriteIds = <int>[].obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final box = GetStorage();
  final localFavoriteApartments =
      <int, ApartmentModel>{}.obs; // Store local apartment data
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    print('❤️ FavoriteController initialized');
    _loadOnStart();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _loadOnStart() {
    Future.delayed(Duration(milliseconds: 500), () {
      _checkLoginAndLoad();
    });
  }

  void _checkLoginAndLoad() async {
    final token = box.read('token');
    if (token != null) {
      await loadFavoriteApartments();
    } else {
      print('👤 No user logged in');
      isLoading.value = false;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 60), (_) {
      final token = box.read('token');
      if (token != null && !isLoading.value) {
        print('🔄 Auto-refreshing favorites...');
        loadFavoriteApartments(silent: true);
      }
    });
  }

  Future<void> loadFavoriteApartments({bool silent = false}) async {
    final token = box.read('token');
    if (token == null) {
      print('🚫 User not logged in');
      if (!silent) isLoading.value = false;
      return;
    }

    if (!silent) {
      isLoading.value = true;
    }

    print('❤️ Loading favorite apartments...');

    try {
      // Get favorite IDs from API
      final apiApartments = await ApiService.getFavoriteApartments();
      print('✅ Loaded ${apiApartments.length} favorite apartments from API');

      // Use local stored data if available, otherwise use API data
      final List<ApartmentModel> apartmentsToShow = [];
      for (final apiApt in apiApartments) {
        final localApt = localFavoriteApartments[apiApt.id];
        if (localApt != null) {
          apartmentsToShow.add(localApt);
          print('📦 Using local data for apartment ${apiApt.id}');
        } else {
          apartmentsToShow.add(apiApt);
          print('🌐 Using API data for apartment ${apiApt.id}');
        }
      }

      favoriteApartments.assignAll(apartmentsToShow);
      favoriteIds.assignAll(apartmentsToShow.map((apt) => apt.id).toList());

      hasError.value = false;
      update();
    } catch (e) {
      print('❌ Error loading favorites: $e');
      hasError.value = true;
      errorMessage.value = e.toString();

      favoriteApartments.clear();
      favoriteIds.clear();
    } finally {
      if (!silent) isLoading.value = false;
    }
  }
/*
  void _loadFromCache(String token) {
    final cached = box.read('favorites_cache_$token');
    if (cached != null && cached is List) {
      try {
        final apartments = <ApartmentModel>[];

        for (var item in cached) {
          try {
            final apartment = ApartmentModel(
              id: item['id'] ?? 0,
              name: item['name']?.toString() ?? '',
              province: item['province']?.toString(),
              city: item['city']?.toString(),
              address: item['address']?.toString(),
              description: item['description']?.toString(),
              dailyPrice:
                  item['daily_price'] != null
                      ? double.tryParse(item['daily_price'].toString())
                      : null,
              monthlyPrice:
                  item['monthly_price'] != null
                      ? double.tryParse(item['monthly_price'].toString())
                      : null,
              yearlyPrice:
                  item['yearly_price'] != null
                      ? double.tryParse(item['yearly_price'].toString())
                      : null,
              images:
                  (item['images'] as List<dynamic>? ?? [])
                      .map((img) => img.toString())
                      .toList(),
              ownerName: item['owner_name']?.toString(),
              ownerImage: item['owner_image']?.toString(),
            );
            apartments.add(apartment);
          } catch (e) {
            print('⚠️ Error parsing cached item: $e');
          }
        }

        favoriteApartments.assignAll(apartments);
        favoriteIds.assignAll(apartments.map((apt) => apt.id).toList());
        hasError.value = false;
        print('📦 Loaded ${apartments.length} favorites from cache');
      } catch (cacheError) {
        print('❌ Cache parsing error: $cacheError');
      }
    }
  }*/

  Future<void> toggleFavorite(ApartmentModel apartment) async {
    final token = box.read('token');
    if (token == null) {
      Get.snackbar('Error', 'Please login first');
      Get.toNamed('/login');
      return;
    }
    final isCurrentlyFavorite = favoriteIds.contains(apartment.id);
    if (isCurrentlyFavorite) {
      favoriteApartments.removeWhere((apt) => apt.id == apartment.id);
      favoriteIds.remove(apartment.id);
    } else {
      favoriteApartments.add(apartment);
      favoriteIds.add(apartment.id);
    }
    update();
    try {
      final response = await ApiService.toggleFavorite(apartment.id);

      if (response.statusCode == 200) {
        Get.snackbar(
          isCurrentlyFavorite ? 'Removed' : 'Added',
          isCurrentlyFavorite ? 'Removed from favorites' : 'Added to favorites',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        if (isCurrentlyFavorite) {
          favoriteApartments.add(apartment);
          favoriteIds.add(apartment.id);
        } else {
          favoriteApartments.removeWhere((apt) => apt.id == apartment.id);
          favoriteIds.remove(apartment.id);
        }
        update();
        Get.snackbar('Error', 'Failed to update favorite');
      }
    } catch (e) {
      if (isCurrentlyFavorite) {
        favoriteApartments.add(apartment);
        favoriteIds.add(apartment.id);
      } else {
        favoriteApartments.removeWhere((apt) => apt.id == apartment.id);
        favoriteIds.remove(apartment.id);
      }
      update();
      Get.snackbar('Error', 'Connection failed');
    }
    Future.delayed(Duration(seconds: 1), () {
      loadFavoriteApartments(silent: true);
    });
  }

  bool isApartmentFavorite(int apartmentId) {
    return favoriteIds.contains(apartmentId);
  }

  Future<void> refreshFavorites() async {
    await loadFavoriteApartments();
  }

  void clearFavorites() {
    final token = box.read('token');
    if (token != null) {
      box.remove('favorites_cache_$token');
    }
    favoriteApartments.clear();
    favoriteIds.clear();
    localFavoriteApartments.clear();
  }
}
