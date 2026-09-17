import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:domus/model/apartment_model.dart';
import 'package:domus/model/booking_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.107:8000/api";

  static Future<http.Response> signup({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String role,
    required String birthDate,
    File? profile,
    File? identity,
  }) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/signup"));

    request.fields.addAll({
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "password": password,
      "password_confirmation": password,
      "role": role.toLowerCase(),
      "date_of_birth": birthDate,
    });

    if (profile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("profile_image", profile.path),
      );
    }

    if (identity != null) {
      request.files.add(
        await http.MultipartFile.fromPath("id_image", identity.path),
      );
    }

    final response = await request.send();
    print(response);
    return await http.Response.fromStream(response);
  }

  static Future<http.Response> login({
    required String phone,
    required String password,
  }) async {
    return await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Accept": "application/json"},
      body: {"phone": phone, "password": password},
    );
  }

  static Future<void> logout() async {
    final box = GetStorage();
    final token = box.read("token");

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        print("Logout failed: ${response.body}");
      }
    } catch (e) {
      print("Logout error: $e");
    }
  }

  static Future<http.Response> forgetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final box = GetStorage();
    final token = box.read("token");
    print("TOKEN SENT => $token");
    return await http.post(
      Uri.parse("$baseUrl/forgetPassword"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "new_password": newPassword,
        "new_password_confirmation": confirmPassword,
      },
    );
  }

  static Future<List<dynamic>> getApartments() async {
    final token = GetStorage().read('token');

    final response = await http.get(
      Uri.parse("$baseUrl/showAllApartments"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    print("GET Apartments Response: ${response.statusCode}");
    print("GET Apartments Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Data received: $body");
      return body['data'];
    } else {
      throw Exception("Failed to load apartments${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>?> getApartmentDetails(int id) async {
    final token = GetStorage().read('token');

    final response = await http.get(
      Uri.parse("$baseUrl/showOneApartment/$id"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    print("📱 GET Apartment Details Response: ${response.statusCode}");
    print("📱 GET Apartment Details Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("📱 Details data received: ${body['data']}");
      return body['data'];
    } else {
      print("❌ Failed to load apartment details: ${response.statusCode}");
      return null;
    }
  }

  static Future<List<ApartmentModel>> getOwnerApartments() async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/owner/apartments'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    print("Owner Apartments Response: ${response.statusCode}");
    print("Owner Apartments Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => ApartmentModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load owner apartments: ${response.statusCode}',
      );
    }
  }

  static Future<http.Response> addApartment({
    required String name,
    required String province,
    required String city,
    String? address,
    String? description,
    double? dailyPrice,
    double? monthlyPrice,
    double? yearlyPrice,
    required List<XFile> images,
  }) async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Not authenticated');
    }
    print("📤 Sending apartment data to API...");
    print("📤 Token: ${token.substring(0, 20)}...");
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/store"));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['name_of_apartment'] = name;
    request.fields['province'] = province;
    request.fields['city'] = city;
    if (address != null && address.isNotEmpty) {
      request.fields['address'] = address;
    }
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (dailyPrice != null) {
      request.fields['daily_price'] = dailyPrice.toString();
    }
    if (monthlyPrice != null) {
      request.fields['monthly_price'] = monthlyPrice.toString();
    }
    if (yearlyPrice != null) {
      request.fields['yearly_price'] = yearlyPrice.toString();
    }
    print("📤 Fields: ${request.fields}");
    for (int i = 0; i < images.length; i++) {
      var image = images[i];
      print("📤 Adding image $i: ${image.path}");

      try {
        var multipartFile = await http.MultipartFile.fromPath(
          'apartment_images[]',
          image.path,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        request.files.add(multipartFile);
      } catch (e) {
        print("❌ Error adding image $i: $e");
      }
    }

    print("📤 Total files: ${request.files.length}");

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📤 API Response Status: ${response.statusCode}");
      print("📤 API Response Body: ${response.body}");

      return response;
    } catch (e) {
      print("❌ API Request Error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Not authenticated');
    }
    try {
      print("📡 Fetching user profile...");
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Profile Response: ${response.statusCode}");
      print("📡 Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error in getUserProfile: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> searchApartments({
    String? province,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }
    final Map<String, String> params = {};

    if (province != null && province.isNotEmpty) {
      params['province'] = province;
    }

    if (city != null && city.isNotEmpty) {
      params['city'] = city;
    }

    if (minPrice != null && minPrice > 0) {
      params['min_price'] = minPrice.toString();
    }

    if (maxPrice != null && maxPrice > 0) {
      params['max_price'] = maxPrice.toString();
    }

    final url = Uri.parse(
      '$baseUrl/Filtering',
    ).replace(queryParameters: params);

    print('🌐 إرسال طلب إلى: $url');
    print('🔑 التوكن: ${token.substring(0, 20)}...');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('📥 حالة الرد: ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // محاولة قراءة رسالة الخطأ
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'حدث خطأ غير معروف';
        throw Exception('خطأ ${response.statusCode}: $errorMessage');
      } catch (_) {
        throw Exception('فشل في البحث (${response.statusCode})');
      }
    }
  }

  static Future<http.Response> createBooking({
    required int apartmentId,
    required String startDate,
    required String endDate,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    print('📤 Creating booking...');
    print('🏠 Apartment ID: $apartmentId');
    print('📅 Start Date: $startDate');
    print('📅 End Date: $endDate');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'apartment_id': apartmentId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      print('📥 Booking Response Status: ${response.statusCode}');
      print('📥 Booking Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ API Error in createBooking: $e');
      rethrow;
    }
  }

  static Future<http.Response> bookApartment({
    required int apartmentId,
    required String startDate,
    required String endDate,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    return await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'apartment_id': apartmentId,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
  }

  static Future<List<DateTime>> getBookedDates(int apartmentId) async {
    try {
      final token = GetStorage().read('token');
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/apartments/$apartmentId/booked-dates'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dates = data['booked_dates'] ?? [];
        return dates.map((date) => DateTime.parse(date)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching booked dates: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getMyBookings() async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📥 Fetching user bookings...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/myGroupedBookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Bookings response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      rethrow;
    }
  }

  static Future<http.Response> updateBooking({
    required int bookingId,
    required String startDate,
    required String endDate,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    return await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'start_date': startDate, 'end_date': endDate}),
    );
  }

  // في api_service.dart
  static Future<http.Response> approveModification(int bookingId) async {
    final token = GetStorage().read('token');
    return await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/approve-modification'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> rejectModification(
    int bookingId, {
    String? reason,
  }) async {
    final token = GetStorage().read('token');
    return await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/reject-modification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reason': reason}),
    );
  }

  static Future<http.Response> cancelBooking(int bookingId) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('🗑️ Canceling booking ID: $bookingId');

    return await http.delete(
      Uri.parse('$baseUrl/deleteBooking/$bookingId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }

  static Future<Map<String, dynamic>> getOwnerBookings() async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📥 Fetching owner bookings...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/owner/bookings/pending'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to fetch owner bookings: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching owner bookings: $e');
      rethrow;
    }
  }

  static Future<http.Response> approveBooking(int bookingId) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('✅ Approving booking ID: $bookingId');

    return await http.put(
      Uri.parse('$baseUrl/approve/$bookingId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> rejectBooking(
    int bookingId, {
    String? reason,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('❌ Rejecting booking ID: $bookingId');

    final Map<String, dynamic> body = {};
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    return await http.put(
      Uri.parse('$baseUrl/reject/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<List<BookingModel>> getApartmentBookings(
    int apartmentId,
  ) async {
    final token = GetStorage().read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📥 Fetching bookings for apartment $apartmentId');

    final response = await http.get(
      Uri.parse('$baseUrl/owner/apartments/$apartmentId/bookings'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('📥 Response status: ${response.statusCode}');
    print(
      '📥 Response body: ${response.body.substring(0, min(200, response.body.length))}...',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<dynamic> bookingsData = [];

      if (data is Map<String, dynamic>) {
        print('📥 Parsing structured data...');
        print('📥 Available keys: ${data.keys.toList()}');

        if (data.containsKey('data') &&
            data['data'] is Map &&
            data['data'].containsKey('data') &&
            data['data']['data'] is List) {
          bookingsData = data['data']['data'] as List<dynamic>;
          print('📥 Found data in data.data.data');
        } else if (data.containsKey('bookings') && data['bookings'] is List) {
          bookingsData = data['bookings'] as List<dynamic>;
          print('📥 Found data directly in bookings');
        } else if (data.containsKey('data') && data['data'] is List) {
          bookingsData = data['data'] as List<dynamic>;
          print('📥 Found data directly in data');
        }
      }

      print('📥 Extracted bookings count: ${bookingsData.length}');
      if (bookingsData.isNotEmpty) {
        print('📋 Sample of first booking: ${bookingsData.first}');
      }

      return bookingsData.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch bookings: ${response.statusCode}');
    }
  }

  static Future<http.Response> toggleFavorite(int apartmentId) async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('You must log in first');
    }

    print('❤️ Add/Remove from favorites for apartment ID: $apartmentId');

    return await http.post(
      Uri.parse('$baseUrl/addtofavorites/$apartmentId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }

  static Future<List<dynamic>> getFavorites() async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📥 Fetching favorites list...');

    final response = await http.get(
      Uri.parse('$baseUrl/getFavorites'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('📥 Favorites response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to fetch favorites: ${response.statusCode}');
    }
  }

  static Future<List<ApartmentModel>> getFavoriteApartments() async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📥 Fetching favorite apartments for current user...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getFavorites'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch favorites: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final favoritesList = data['data'] as List;

      print(
        '✅ Number of favorite apartments for this user: ${favoritesList.length}',
      );

      final List<ApartmentModel> apartments = [];

      for (var item in favoritesList) {
        try {
          final apartment = ApartmentModel.fromJson(item);
          apartments.add(apartment);
          print('✅ Added apartment: ${apartment.name}');
        } catch (e) {
          print('❌ Error converting apartment data: $e');
          print('❌ Data: $item');
        }
      }

      return apartments;
    } catch (e) {
      print('❌ Error in getFavoriteApartments: $e');
      rethrow;
    }
  }
  // ⬇️ **أضف هذه الدوال في نهاية الكلاس**

  // إرسال تقييم جديد
  static Future<http.Response> submitRating({
    required int apartmentId,
    required int rating,
    String? comment,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    print('⭐ Submitting rating for apartment $apartmentId');
    print('⭐ Rating: $rating, Comment: $comment');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Rating/$apartmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );

      print('⭐ Rating Response Status: ${response.statusCode}');
      print('⭐ Rating Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ Error submitting rating: $e');
      rethrow;
    }
  }

  // جلب متوسط التقييم
  static Future<Map<String, dynamic>> getAverageRating(int apartmentId) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    print('📊 Fetching average rating for apartment $apartmentId');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/apartments/$apartmentId/average-rating'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Average Rating Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        print('📊 Error response: ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Error fetching average rating: $e');
      return {};
    }
  }

  // Check user eligibility for rating
  static Future<Map<String, dynamic>> checkRatingEligibility(
    int apartmentId,
  ) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      return {'can_rate': false, 'reason': 'You must log in first'};
    }

    print('🔍 Checking rating eligibility for apartment $apartmentId');
    print('🔑 Token exists: ${token != null}');
    print('🔑 Token length: ${token?.length ?? 0}');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/apartments/$apartmentId/check-rating'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Eligibility Response Status: ${response.statusCode}');
      print('🔍 Eligibility Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 Parsed data: $data');
        return data['data'] ?? {'can_rate': false, 'reason': 'Unknown'};
      } else if (response.statusCode == 401) {
        print('🔍 Authentication failed - token might be invalid');
        return {
          'can_rate': false,
          'reason': 'Authentication problem - please log in again',
        };
      } else if (response.statusCode == 404) {
        print('🔍 Endpoint not found - backend needs implementation');
        return {
          'can_rate': false,
          'reason': 'Rating service not currently available',
        };
      } else {
        print('🔍 Unexpected status code: ${response.statusCode}');
        return {
          'can_rate': false,
          'reason': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ Error checking eligibility: $e');
      return {'can_rate': false, 'reason': 'Connection error: $e'};
    }
  }

  // Get apartment ratings (public)
  static Future<Map<String, dynamic>> getApartmentRatings(
    int apartmentId, {
    int page = 1,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('📄 Fetching ratings for apartment $apartmentId, page $page');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/apartments/$apartmentId/public-ratings?page=$page'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch ratings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching ratings: $e');
      rethrow;
    }
  }

  // Delete rating
  static Future<http.Response> deleteRating(int ratingId) async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      throw Exception('You must log in first');
    }

    print('🗑️ Deleting rating $ratingId');

    final response = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('🗑️ Delete Rating Response: ${response.statusCode}');
    print('🗑️ Delete Rating Body: ${response.body}');

    return response;
  }
// lib/services/api_service.dart - أضف هذه الدوال
static Future<Map<String, dynamic>> getChats() async {
  final box = GetStorage();
  final token = box.read('token');
  
  if (token == null) {
    return {'success': false, 'message': 'Not logged in'};
  }
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/chats'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data['data'] ?? []};
    }
    
    return {'success': false, 'message': 'Failed to load chats'};
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> sendMessage(int chatId, String message) async {
  // TODO: Implement send message API
  return {'success': true, 'message': 'Message sent'};
}

static Future<Map<String, dynamic>> deleteChat(int chatId) async {
  // TODO: Implement delete chat API
  return {'success': true, 'message': 'Chat deleted'};
}

}
