import 'package:domus/controller/adding_controller.dart';
import 'package:domus/controller/booking_controller.dart';
import 'package:domus/controller/chat_controller.dart';
import 'package:domus/controller/details_controller.dart';
import 'package:domus/controller/edit_booking_controller.dart';
import 'package:domus/controller/explore_controller.dart';
import 'package:domus/controller/favorite_controller.dart';
import 'package:domus/controller/filter_controller.dart';
import 'package:domus/controller/forget_password_controller.dart';
import 'package:domus/controller/local_rating_controller.dart';
import 'package:domus/controller/login_controller.dart';
import 'package:domus/controller/mybooking_controller.dart';
import 'package:domus/controller/search_controller.dart';
import 'package:domus/controller/signupcontroller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreController>(() => ExploreController());
  }
}

class FilteringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FilteringController>(() => FilteringController());
  }
}

class ForgetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgetPasswordController>(() => ForgetPasswordController());
  }
}

class DetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocalRatingController>(LocalRatingController(), permanent: true);

    Get.lazyPut<DetailsController>(() => DetailsController());
  }
}

class AddingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddingApartmentController>(() => AddingApartmentController());
  }
}

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookingsController());
  }
}

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
  }
}

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FavoriteController>(FavoriteController(), permanent: false);
  }
}

class EditBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditBookingController>(() => EditBookingController());
  }
}

class LocalRatingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalRatingController>(() => LocalRatingController());
  }
}
class ChatBinding implements Bindings {
  @override
  void dependencies() {
    print('🔗 ChatBinding dependencies loaded');
    
    // استخدام lazyPut مع fenix: true لإعادة التحميل عند الحاجة
    Get.lazyPut<ChatController>(
      () => ChatController(),
      fenix: true, // ⭐ مهم لإعادة الإنشاء عند إغلاق الصفحة
      tag: 'chat',
    );
  }
}
