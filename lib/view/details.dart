import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/view/component/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controller/details_controller.dart';

class DetailsPage extends GetView<DetailsController> {
  DetailsPage({super.key});

  final PageController _pageController = PageController();
  final currentImageIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final apt = controller.apartment.value;
      if (apt == null) {
        return const Scaffold(
          body: Center(
            child: Text(
              "Apartment details not available",
              style: TextStyle(fontSize: 16, fontFamily: "Nunito"),
            ),
          ),
        );
      }

      return Scaffold(
        //  backgroundColor: AppColors.lightBackground,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            //  color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  final apt = controller.apartment.value;
                  if (apt != null) {
                    Get.toNamed(
                      '/book-now',
                      arguments: {
                        'id': apt.id,
                        'name_of_apartment': apt.name,
                        'province': apt.province,
                        'city': apt.city,
                        'address': apt.address,
                        'daily_price': apt.dailyPrice,
                        'monthly_price': apt.monthlyPrice,
                        'yearly_price': apt.yearlyPrice,
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Ionicons.calendar_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Nunito",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 330,
                width: double.infinity,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        currentImageIndex.value = index;
                      },
                      itemCount: apt.images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                          child: Container(
                            //  color: Colors.grey[200],
                            child: Image.network(
                              apt.images[index],
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    if (apt.images.length > 1)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(apt.images.length, (i) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        currentImageIndex.value == i
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 20,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 16,
                      child: GetBuilder<FavoriteController>(
                        init: FavoriteController(),
                        builder: (favController) {
                          final isFavorite = favController.isApartmentFavorite(
                            apt.id,
                          );
                          return CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color:
                                    isFavorite ? Colors.red : AppColors.primary,
                              ),
                              onPressed: () async {
                                await favController.toggleFavorite(apt);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 16,
                      child: GetBuilder<FavoriteController>(
                        builder: (favController) {
                          final apt = controller.apartment.value;
                          if (apt == null) return const SizedBox();

                          final isFavorite = favController.isApartmentFavorite(
                            apt.id,
                          );
                          return CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color:
                                    isFavorite ? Colors.red : AppColors.primary,
                              ),
                              onPressed: () async {
                                await favController.toggleFavorite(apt);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apt.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Nunito",
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${apt.province} - ${apt.city} - ${apt.address} ",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.button,
                                fontFamily: "Nunito",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  apt.description ?? "No description available",
                  style: const TextStyle(fontSize: 14, fontFamily: "Nunito"),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Booking Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _priceRow("Daily Price", "${apt.dailyPrice ?? '-'} \$"),
                    _priceRow("Monthly Price", "${apt.monthlyPrice ?? '-'} \$"),
                    _priceRow("Yearly Price", "${apt.yearlyPrice ?? '-'} \$"),
                  ],
                ),
              ),
              // ⬇️ **استبدال قسم التقييم الحالي بهذا الكود**
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Ratings",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Average Rating
                    Obx(
                      () => Column(
                        children: [
                          if (controller.averageRating.value > 0) ...[
                            Text(
                              controller.ratingText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            SizedBox(height: 10),

                            // Show stars for average
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 30,
                                  color:
                                      index <
                                              controller.averageRating.value
                                                  .round()
                                          ? Colors.amber
                                          : Colors.grey[300],
                                );
                              }),
                            ),
                            SizedBox(height: 20),
                          ] else ...[
                            Text(
                              'No ratings yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),

                    // Check eligibility
                    Obx(() {
                      if (controller.isCheckingEligibility.value) {
                        return CircularProgressIndicator();
                      }

                      if (controller.canRate.value) {
                        return Column(
                          children: [
                            Text(
                              'Rate your experience with this apartment:',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 15),

                            // Stars for rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () => controller.setRating(index + 1),
                                  child: Obx(
                                    () => Icon(
                                      Icons.star,
                                      size: 40,
                                      color:
                                          index < controller.rating.value
                                              ? AppColors.details
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }),
                            ),

                            SizedBox(height: 10),
                            Obx(
                              () => Text(
                                "${controller.rating.value} / 5",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Nunito",
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: () => controller.showRatingDialog(),
                              icon: Icon(Icons.rate_review, size: 20),
                              label: Text('Add Comment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            if (controller.ratingEligibility['reason'] != null)
                              Text(
                                controller.ratingEligibility['reason'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Nunito',
                                ),
                                textAlign: TextAlign.center,
                              ),

                            SizedBox(height: 15),

                            // Show user's rating if exists
                            Obx(() {
                              final localRating = controller.rating.value;
                              if (localRating > 0) {
                                return Column(
                                  children: [
                                    Text(
                                      'Your previous rating:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          size: 24,
                                          color:
                                              index < localRating
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                        );
                                      }),
                                    ),
                                    Text(
                                      '$localRating / 5',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return SizedBox();
                            }),
                          ],
                        );
                      }
                    }),

                    // Button to show all ratings
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // ⬇️ You will create the ratings page in the next step
                        if (controller.apartment.value != null) {
                          Get.toNamed(
                            '/apartment-ratings',
                            arguments: controller.apartment.value!.id,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reviews, size: 18),
                          SizedBox(width: 8),
                          Obx(
                            () => Text(
                              'Show all ratings (${controller.ratingsCount.value})',
                              style: TextStyle(fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    "Published by",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Ionicons.person_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    apt.ownerName ?? "Unknown",
                    style: const TextStyle(
                      color: AppColors.thirdly,
                      fontSize: 14,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      apt.ownerImage != null
                          ? NetworkImage(apt.ownerImage!)
                          : null,
                  backgroundColor: Colors.grey.shade200,
                  child:
                      apt.ownerImage == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }

  Widget _priceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title + ":",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Nunito",
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.details,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
