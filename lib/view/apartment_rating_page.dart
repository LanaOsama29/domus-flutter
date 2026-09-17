import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domus/controller/remote_rating_controller.dart';
import 'package:domus/view/component/color.dart';

class ApartmentRatingsPage extends StatefulWidget {
  final int apartmentId;

  const ApartmentRatingsPage({Key? key, required this.apartmentId})
    : super(key: key);

  @override
  _ApartmentRatingsPageState createState() => _ApartmentRatingsPageState();
}

class _ApartmentRatingsPageState extends State<ApartmentRatingsPage> {
  final RemoteRatingController ratingController =
      Get.find<RemoteRatingController>();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  List<dynamic> _ratings = [];
  Map<String, dynamic>? _apartmentInfo;
  Map<String, dynamic>? _ratingSummary;

  @override
  void initState() {
    super.initState();
    _loadRatings();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadRatings({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _ratings = [];
      }
    });

    try {
      final result = await ratingController.getApartmentRatings(
        widget.apartmentId,
        page: _currentPage,
      );

      if (result['success'] == true) {
        final newRatings = result['ratings'] as List<dynamic>;

        setState(() {
          if (refresh) {
            _ratings = newRatings;
          } else {
            _ratings.addAll(newRatings);
          }

          _apartmentInfo = result['apartment'];
          _ratingSummary = result['summary'];

          final pagination = result['pagination'];
          _hasMore = pagination['current_page'] < pagination['last_page'];

          if (!refresh && newRatings.isNotEmpty) {
            _currentPage++;
          }
        });
      }
    } catch (e) {
      print('Error loading ratings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadRatings();
      }
    }
  }

  Widget _buildRatingSummary() {
    if (_ratingSummary == null) return SizedBox();

    final total =
        _ratingSummary!['5_stars'] +
        _ratingSummary!['4_stars'] +
        _ratingSummary!['3_stars'] +
        _ratingSummary!['2_stars'] +
        _ratingSummary!['1_stars'];

    if (total == 0) return SizedBox();

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ratings Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 10),

            // Stars distribution
            _buildStarBar(5, _ratingSummary!['5_stars'], total),
            _buildStarBar(4, _ratingSummary!['4_stars'], total),
            _buildStarBar(3, _ratingSummary!['3_stars'], total),
            _buildStarBar(2, _ratingSummary!['2_stars'], total),
            _buildStarBar(1, _ratingSummary!['1_stars'], total),
          ],
        ),
      ),
    );
  }

  Widget _buildStarBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars ⭐', style: TextStyle(fontSize: 14)),
          SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: percentage * 3,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            '$count (${percentage.toStringAsFixed(0)}%)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> rating) {
    final renter = rating['renter'] ?? {};
    final renterName =
        '${renter['first_name'] ?? ''} ${renter['last_name'] ?? ''}'.trim();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        renterName.isNotEmpty ? renterName : 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        _formatDate(rating['created_at']),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color:
                          index < (rating['rating'] as int? ?? 0)
                              ? Colors.amber
                              : Colors.grey[300],
                    );
                  }),
                ),
              ],
            ),

            SizedBox(height: 12),

            if (rating['comment'] != null &&
                rating['comment'].toString().isNotEmpty)
              Text(
                rating['comment'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _apartmentInfo?['name'] ?? 'Apartment Ratings',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadRatings(refresh: true),
          ),
        ],
      ),
      body: Obx(() {
        if (ratingController.isLoading.value && _ratings.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => _loadRatings(refresh: true),
          child: ListView(
            controller: _scrollController,
            children: [
              // Apartment info
              if (_apartmentInfo != null)
                Container(
                  padding: EdgeInsets.all(16),
                  color: AppColors.primary.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _apartmentInfo!['name']?.toString() ??
                                'Unspecified Apartment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(_apartmentInfo!['average_rating'] ?? 0.0).toString()} ⭐ (${_apartmentInfo!['ratings_count'] ?? 0} rating${(_apartmentInfo!['ratings_count'] ?? 0) != 1 ? 's' : ''})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.apartment, size: 40, color: AppColors.primary),
                    ],
                  ),
                ),

              // Ratings distribution
              _buildRatingSummary(),

              // Ratings list
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'All Ratings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),

              if (_ratings.isEmpty)
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.reviews, size: 60, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        'No ratings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._ratings.map((rating) => _buildRatingItem(rating)).toList(),

              // Loading indicator for more
              if (_isLoading && _ratings.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (!_hasMore && _ratings.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No more ratings',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
