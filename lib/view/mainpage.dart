import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:domus/controller/chat_controller.dart';
import 'package:domus/controller/explore_controller.dart';
import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/controller/mybooking_controller.dart';
import 'package:domus/view/booking.dart';
import 'package:domus/view/chat.dart';
import 'package:domus/view/component/color.dart';
import 'package:domus/view/favorite.dart';

import 'package:domus/view/explore.dart';
import 'package:domus/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    Get.put(ExploreController());
    Get.put(BookingsController(), permanent: true);
    Get.put(FavoriteController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = box.read('token');
      if (token != null) {
        Future.delayed(Duration(seconds: 1), () {
          final bookingsController = Get.find<BookingsController>();
          bookingsController.loadMyBookings();
        });
        Future.delayed(Duration(seconds: 2), () {
          final favoriteController = Get.find<FavoriteController>();
          favoriteController.loadFavoriteApartments();
        });
      }
    });
  }

  final List<Widget> pages = const [
    ExplorePage(),
    MyBookingsPage(),
    FavoritePage(),
    ChatPage(),
    SettingPage(),
  ];

  final navigationItems = const [
    Icon(Icons.explore_outlined, size: 30, color: AppColors.details),
    Icon(Icons.event_available_outlined, size: 30, color: AppColors.details),
    Icon(Icons.favorite_border_outlined, size: 30, color: AppColors.details),
    Icon(
      Icons.chat_bubble_outline_outlined,
      size: 30,
      color: AppColors.details,
    ),
    Icon(Icons.settings, size: 30, color: AppColors.details),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],

      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        items: navigationItems,
        color: AppColors.primary,
        backgroundColor: Colors.transparent,
        height: 55,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          final token = box.read('token');
          if (token != null) {
            if (index == 1) {
              final bookingsController = Get.find<BookingsController>();
              bookingsController.loadMyBookings();
            } else if (index == 2) {
              final favoriteController = Get.find<FavoriteController>();
              favoriteController.loadFavoriteApartments();
            }
          }
        },
      ),
    );
  }
}
