import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:domus/controller/explore_controller.dart';
import 'package:domus/model/apartment_model.dart';

class SearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final RxList<ApartmentModel> searchResults = <ApartmentModel>[].obs;
  final RxList<String> searchHistory = <String>[].obs; 
  final RxList<ApartmentModel> recentSearches = <ApartmentModel>[].obs; 
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt totalApartments = 0.obs;
  final RxBool showHistory = true.obs; 
  final GetStorage _storage = GetStorage();
  ExploreController get exploreController => Get.find<ExploreController>();

  @override
  void onInit() {
    super.onInit();
    print('🔍 SearchController initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });

    ever(searchQuery, (_) => _performSearch());

    totalApartments.value = exploreController.apartments.length;

    _loadSearchHistory();
    _loadRecentSearches();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }


  void _loadSearchHistory() {
    final history = _storage.read<List>('search_history') ?? [];
    searchHistory.value = history.cast<String>();
    print('📚 Loaded search history: $history');
  }

  void _loadRecentSearches() {
    final recentIds = _storage.read<List>('recent_search_ids') ?? [];
    for (final id in recentIds) {
      final apartment = exploreController.apartments.firstWhereOrNull(
        (apt) => apt.id == id
      );
      if (apartment != null) {
        recentSearches.add(apartment);
      }
    }
    print('📚 Loaded ${recentSearches.length} recent searches');
  }

  void _saveToSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    searchHistory.insert(0, query.trim());

    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }
    
    _storage.write('search_history', searchHistory);
    print('💾 Saved search query: $query');
  }

  void _saveToRecentSearches(ApartmentModel apartment) {

    recentSearches.removeWhere((item) => item.id == apartment.id);

    recentSearches.insert(0, apartment);

    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    final ids = recentSearches.map((apt) => apt.id).toList();
    _storage.write('recent_search_ids', ids);
    print('💾 Saved recent search: ${apartment.name}');
  }

  void clearSearchHistory() {
    searchHistory.clear();
    recentSearches.clear();
    _storage.remove('search_history');
    _storage.remove('recent_search_ids');
    Get.snackbar(
      'History Cleared',
      'Search history has been cleared',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  void removeFromHistory(String query) {
    searchHistory.remove(query);
    _storage.write('search_history', searchHistory);
    Get.snackbar(
      'Removed',
      'Removed "$query" from history',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();
    showHistory.value = query.isEmpty;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    showHistory.value = true;
  }

  void _performSearch() {
    final query = searchQuery.value;
    
    if (query.isEmpty) {
      searchResults.clear();
      showHistory.value = true;
      return;
    }

    showHistory.value = false;
    isLoading.value = true;

    final lowerQuery = query.toLowerCase();
    final results = <ApartmentModel>[];

    for (final apartment in exploreController.apartments) {
      bool matches = false;

      if (apartment.name.toLowerCase().contains(lowerQuery)) {
        matches = true;
      }
      else if (apartment.province != null && 
               apartment.province!.toLowerCase().contains(lowerQuery)) {
        matches = true;
      }

      else if (apartment.city != null && 
               apartment.city!.toLowerCase().contains(lowerQuery)) {
        matches = true;
      }

      else if (apartment.address != null && 
               apartment.address!.toLowerCase().contains(lowerQuery)) {
        matches = true;
      }
      else if (apartment.description != null && 
               apartment.description!.toLowerCase().contains(lowerQuery)) {
        matches = true;
      }

      if (matches) {
        results.add(apartment);
      }
    }

    searchResults.value = results;
    isLoading.value = false;

    if (results.isNotEmpty) {
      _saveToSearchHistory(query);
    }
    
    print('🔍 Search for "$query" found ${results.length} results');
  }

  void searchFromHistory(String query) {
    searchController.text = query;
    updateSearchQuery(query);
    searchFocusNode.requestFocus();
  }

  void goToApartmentDetails(ApartmentModel apartment) {

    _saveToRecentSearches(apartment);
    
    Get.back(); 
    Get.toNamed('/details', arguments: apartment.id);
  }
  List<String> getSuggestedSearches(String partialQuery) {
    if (partialQuery.isEmpty) return [];
    
    return searchHistory
        .where((query) => query.toLowerCase().contains(partialQuery.toLowerCase()))
        .take(5)
        .toList();
  }
}