import 'package:domus/model/apartment_model.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:domus/controller/search_controller.dart';
import 'package:domus/view/component/color.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchHeader(h),
          Expanded(
            child: Obx(() {
              if (controller.showHistory.value &&
                  controller.searchQuery.value.isEmpty) {
                return _buildSearchHistory();
              }
              return _buildSearchResults();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(double h) {
    return Container(
      height: h * 0.18,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: h * 0.06),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(
                            () => TextField(
                              controller: controller.searchController,
                              focusNode: controller.searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search apartments...',
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                suffixIcon:
                                    controller.searchQuery.value.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.grey,
                                            size: 18,
                                          ),
                                          onPressed: controller.clearSearch,
                                        )
                                        : null,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Nunito',
                              ),
                              onChanged: controller.updateSearchQuery,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Obx(
            () => Text(
              '${controller.totalApartments.value} apartments available',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      children: [
        if (controller.recentSearches.isNotEmpty)
          _buildSection('Recent Searches', Icons.history),

        if (controller.recentSearches.isNotEmpty)
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.recentSearches.length,
              itemBuilder: (context, index) {
                final apartment = controller.recentSearches[index];
                return _buildRecentApartmentCard(apartment);
              },
            ),
          ),
        if (controller.searchHistory.isNotEmpty)
          _buildSection('Search History', Icons.access_time),
        if (controller.searchHistory.isNotEmpty)
          Expanded(flex: 2, child: _buildSearchHistoryList()),

        // Clear History Button
        if (controller.searchHistory.isNotEmpty ||
            controller.recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: controller.clearSearchHistory,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Clear All History'),
                ],
              ),
            ),
          ),
        if (controller.searchHistory.isEmpty &&
            controller.recentSearches.isEmpty)
          Expanded(
            child: _buildEmptyState(
              'No search history yet\nStart searching for apartments',
              Icons.search,
            ),
          ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApartmentCard(ApartmentModel apartment) {
    final imageUrl = apartment.images.isNotEmpty ? apartment.images.first : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.goToApartmentDetails(apartment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    imageUrl.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        )
                        : Center(
                          child: Icon(
                            Icons.home,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${apartment.province} • ${apartment.city}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${apartment.monthlyPrice?.toStringAsFixed(0) ?? '0'} / month',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.access_time, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.searchHistory.length,
      itemBuilder: (context, index) {
        final query = controller.searchHistory[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.history, color: Colors.grey.shade500, size: 20),
            title: Text(
              query,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
              onPressed: () => controller.removeFromHistory(query),
            ),
            onTap: () => controller.searchFromHistory(query),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.searchQuery.value.isEmpty) {
      return _buildEmptyState(
        'Start typing to search apartments',
        Icons.search,
      );
    }

    if (controller.searchResults.isEmpty) {
      return _buildEmptyState(
        'No apartments found for "${controller.searchQuery.value}"',
        Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final apartment = controller.searchResults[index];
        return _buildApartmentCard(apartment);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(ApartmentModel apartment) {
    final imageUrl = apartment.images.isNotEmpty ? apartment.images.first : '';

    return GestureDetector(
      onTap: () => controller.goToApartmentDetails(apartment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey[200],
                child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.home,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Icon(
                            Icons.home,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${apartment.province} • ${apartment.city}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (apartment.address != null &&
                        apartment.address!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          apartment.address!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${apartment.monthlyPrice?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
