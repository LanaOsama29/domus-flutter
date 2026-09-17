import 'package:domus/Binding/auth_Binding.dart';
import 'package:domus/controller/settings_controller.dart';
import 'package:domus/model/apartment_model.dart';
import 'package:domus/view/adding.dart';
import 'package:domus/view/apartement_book.dart';
import 'package:domus/view/apartment_rating_page.dart';
import 'package:domus/view/book_page.dart';
import 'package:domus/view/booking.dart';
import 'package:domus/view/booking_complete_page.dart';
import 'package:domus/view/chat.dart';
import 'package:domus/view/details.dart';
import 'package:domus/view/edit_booking.dart';
import 'package:domus/view/explore.dart';
import 'package:domus/view/favorite.dart';
import 'package:domus/view/filterpage.dart';
import 'package:domus/view/search.dart';
import 'package:domus/view/mainpage.dart';
import 'package:domus/view/posting.dart';
import 'package:domus/view/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'view/auth/forgetpassword.dart';
import 'view/auth/login.dart';
import 'view/auth/signup.dart';
import 'view/component/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isLoggedIn = box.read('isLoggedIn') ?? false;
    print('Initial Route: ${isLoggedIn ? '/home' : '/login'}');
    print('isLoggedIn value: $isLoggedIn');
    print('Token: ${box.read('token')}');
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppColors.lightTheme,
        darkTheme: AppColors.darkTheme,
        themeMode:
            settingsController.isDarkMode.value
                ? ThemeMode.dark
                : ThemeMode.light,
        initialRoute: isLoggedIn ? '/home' : '/login',
        getPages: [
          GetPage(
            name: '/signup',
            page: () => const Signup(),
            binding: SignupBinding(),
          ),
          GetPage(
            name: '/login',
            page: () => const Login(),
            binding: LoginBinding(),
          ),
          GetPage(name: '/home', page: () => const MainPage()),
          GetPage(
            name: '/explore',
            page: () => const ExplorePage(),
            binding: ExploreBinding(),
          ),
          GetPage(
            name: '/filter',
            page: () => const FilterPage(),
            binding: FilteringBinding(),
          ),
          GetPage(name: '/filter-results', page: () => ResultsPage()),
          GetPage(
            name: "/password",
            page: () => ForgetPassword(),
            binding: ForgetPasswordBinding(),
          ),
          GetPage(name: "/ownerProfile", page: () => const OwnerPostsPage()),
          GetPage(
            name: '/adding',
            page: () => Adding(),
            binding: AddingBinding(),
          ),
          GetPage(
            name: '/details',
            page: () => DetailsPage(),
            binding: DetailsBinding(),
          ),
          GetPage(
            name: '/search',
            page: () => SearchPage(),
            binding: SearchBinding(),
          ),
          GetPage(
            name: '/book-now',
            page: () => const BookNowPage(),
            binding: BookingsBinding(),
          ),

          GetPage(
            name: '/my-bookings',
            page: () => const MyBookingsPage(),
            binding: MyBookingsBinding(),
          ),
          GetPage(
            name: '/apartment-bookings',
            page: () {
              final apartment = Get.arguments as ApartmentModel;
              return ApartmentBookingsPage(apartment: apartment);
            },
          ),
          GetPage(
            name: '/booking-complete',
            page: () => const BookingCompletePage(),
          ),
          GetPage(
            name: '/edit-booking',
            page: () => const EditBookingPage(),
            binding: EditBookingBinding(),
          ),
          GetPage(
            name: '/favorites',
            page: () => const FavoritePage(),
            binding: FavoriteBinding(),
          ),
          GetPage(
            name: '/apartment-ratings',
            page: () {
              final apartmentId = Get.arguments as int;
              return ApartmentRatingsPage(apartmentId: apartmentId);
            },
          ),
          // في main.dart - تحديث GetPages
          GetPage(
            name: '/chats',
            page: () => const ChatPage(),
            binding: ChatBinding(), // ⭐ استخدام Binding
            transition: Transition.rightToLeft, // أنيميشن
          ),
        ],
      ),
    );
  }
}
