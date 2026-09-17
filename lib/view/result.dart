import 'package:domus/controller/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domus/model/apartment_model.dart';
import 'package:domus/view/component/color.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final controller = Get.find<FilteringController>();

    return Scaffold(
      // backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          Container(
            height: h * 0.14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: h * 0.055,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                Positioned(
                  top: h * 0.06,
                  left: 0,
                  right: 0,
                  child: Obx(
                    () => Center(
                      child: Text(
                        "Search Results (${controller.searchResults.length})",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "Nunito",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No properties found",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: "Nunito",
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Try different search criteria",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  try {
                    final item = controller.searchResults[index];
                    final apartment = ApartmentModel.fromJson(item);
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/details', arguments: apartment.id);
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
                                    child:
                                        apartment.images.isNotEmpty
                                            ? Image.network(
                                              apartment.images.first,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Icon(
                                                  Icons.home,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
                                    child: Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                      size: 18,
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
                                      fontFamily: "Nunito",
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
                                          "${apartment.province} - ${apartment.city}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    apartment.monthlyPrice != null
                                        ? "${apartment.monthlyPrice?.toStringAsFixed(0) ?? ''} \$ / month"
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
                  } catch (e) {
                    print('Error loading property: $e');
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Error',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
