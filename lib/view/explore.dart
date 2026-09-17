import 'package:domus/Binding/auth_Binding.dart';
import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/services/api_config.dart';
import 'package:domus/view/details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controller/explore_controller.dart';
import 'component/color.dart';

class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: h * 0.20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: h * 0.07),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/search');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Search for home...",
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                              Icon(
                                Ionicons.search_outline,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        print('🎯 Navigating to filter page...');
                        Get.toNamed('/filter');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.details,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Ionicons.options_sharp,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recommended for you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Nuntio",
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.apartments.isEmpty) {
              return const Center(child: Text("No apartments available"));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: controller.apartments.length,
              itemBuilder: (context, index) {
                final apartment = controller.apartments[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => DetailsPage(),
                      arguments: apartment.id,
                      binding: DetailsBinding(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: SizedBox(
                                height: h * 0.18,
                                width: double.infinity,
                                child: apartmentImage(
                                  apartment.images.isNotEmpty
                                      ? apartment.images.first
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GetBuilder<FavoriteController>(
                                builder: (favController) {
                                  final isFavorite = favController
                                      .isApartmentFavorite(apartment.id);
                                  return GestureDetector(
                                    onTap: () async {
                                      await favController.toggleFavorite(
                                        apartment,
                                      );
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 20,
                                          color:
                                              isFavorite
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "${apartment.province} - ${apartment.address}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                apartment.monthlyPrice != null
                                    ? "${apartment.monthlyPrice ?? ''} \$ / month"
                                    : "Price not available",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

Widget apartmentImage(String? image) {
  if (image == null || image.isEmpty) {
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.home, size: 60, color: Colors.grey[400])),
    );
  }
  if (image.startsWith('http')) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print("❌ Image error: $error for URL: $image");
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
          ),
        );
      },
    );
  } else {
    String cleanImage = image;
    if (cleanImage.startsWith('/storage/')) {
      cleanImage = cleanImage.substring(1);
    }
    if (!cleanImage.startsWith('storage/')) {
      cleanImage = 'storage/$cleanImage';
    }

    final fullUrl = "${ApiConfig.baseUrl}/$cleanImage";
    print("🖼️ Building image URL: $fullUrl");

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print("❌ Image error: $error for URL: $fullUrl");
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
          ),
        );
      },
    );
  }
}
