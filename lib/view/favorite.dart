import 'package:domus/Binding/auth_Binding.dart';
import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/services/api_config.dart';
import 'package:domus/view/details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../view/component/color.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      //  backgroundColor: Colors.white,
      body: Column(
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
                SizedBox(height: h * 0.08),
                const Text(
                  "Favorites",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 8),
                GetBuilder<FavoriteController>(
                  builder: (controller) {
                    return Text(
                      "${controller.favoriteApartments.length} apartment(s)",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: "Nunito",
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Favorite Apartments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Nunito",
                ),
              ),
            ),
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return GetBuilder<FavoriteController>(
      builder: (controller) {
        final box = GetStorage();
        final token = box.read('token');
        if (token == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text(
                  "Please login to view favorites",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontFamily: "Nunito"),
                  ),
                ),
              ],
            ),
          );
        }
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  "Error loading favorites",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.loadFavoriteApartments(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(color: Colors.white, fontFamily: "Nunito"),
                  ),
                ),
              ],
            ),
          );
        }
        if (controller.favoriteApartments.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No apartments in favorites",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontFamily: "Nunito",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tap ♥ on any apartment to add it here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: "Nunito",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshFavorites(),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: controller.favoriteApartments.length,
            itemBuilder: (context, index) {
              final apartment = controller.favoriteApartments[index];
              final h = MediaQuery.of(context).size.height;

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
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await controller.toggleFavorite(
                                        apartment,
                                      );
                                    },
                                  ),
                                ),
                              ),
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
                                    "${apartment.province ?? ''} - ${apartment.city ?? ''}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              apartment.monthlyPrice != null &&
                                      apartment.monthlyPrice! > 0
                                  ? "${apartment.monthlyPrice!.toStringAsFixed(0)} \$ / month"
                                  : "Price upon booking",
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
          ),
        );
      },
    );
  }
}

Widget apartmentImage(String? image) {
  if (image == null || image.isEmpty) {
    print("⚠️ No image provided");
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.home, size: 60, color: Colors.grey[400])),
    );
  }

  print("🖼️ Original image path: $image");

  // التحقق من أنواع المسارات المختلفة
  String finalUrl = image;

  // إذا كان مساراً نسبياً
  if (!image.startsWith('http')) {
    // تنظيف المسار
    String cleanPath = image;

    // إزالة "/" الزائدة في البداية
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // إضافة "storage/" إذا لم يكن موجوداً
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }

    finalUrl = "${ApiConfig.baseUrl}/$cleanPath";
  }

  print("🖼️ Final image URL: $finalUrl");

  return Image.network(
    finalUrl,
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
      print("❌❌❌ IMAGE LOAD ERROR: $error");
      print("❌❌❌ URL attempted: $finalUrl");
      print("❌❌❌ Original path: $image");
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                "Failed to load",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    },
  );
}
