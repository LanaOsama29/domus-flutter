# Laravel Backend Rating Implementation

## Problem
The Flutter app expects rating functionality but the Laravel backend doesn't have the required API endpoints implemented.

## Required API Endpoints
Based on the Flutter API service, these endpoints need to be implemented:

1. `POST /api/Rating/{apartmentId}` - Submit rating
2. `GET /api/apartments/{apartmentId}/average-rating` - Get average rating
3. `GET /api/apartments/{apartmentId}/check-rating` - Check rating eligibility
4. `GET /api/apartments/{apartmentId}/public-ratings` - Get apartment ratings
5. `DELETE /api/ratings/{ratingId}` - Delete rating

## Database Migration
First, create a migration for the ratings table:

```php
// database/migrations/xxxx_create_ratings_table.php
// database/migrations/xxxx_create_ratings_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('apartment_id')->constrained()->onDelete('cascade');
            $table->foreignId('renter_id')->constrained('users')->onDelete('cascade');
            $table->tinyInteger('rating')->unsigned(); // 1-5 stars
            $table->text('comment')->nullable();
            $table->timestamps();

            // One rating per renter per apartment
            $table->unique(['apartment_id', 'renter_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
```

## Rating Model
Create the Rating model:

```php
// app/Models/Rating.php
// app/Models/Rating.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Rating extends Model
{
    use HasFactory;

    protected $fillable = [
        'apartment_id',
        'renter_id',
        'rating',
        'comment',
    ];

    protected $casts = [
        'rating' => 'integer',
    ];

    public function apartment(): BelongsTo
    {
        return $this->belongsTo(Apartment::class);
    }

    public function renter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'renter_id');
    }
}
```

## Rating Controller
Create the RatingController:

```php
// app/Http/Controllers/RatingController.php
// app/Http/Controllers/RatingController.php
<?php

namespace App\Http\Controllers;

use App\Models\Apartment;
use App\Models\Booking;
use App\Models\Rating;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RatingController extends Controller
{
    public function submitRating(Request $request, $apartmentId)
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        // Check if user has completed booking for this apartment
        $hasCompletedBooking = Booking::where('apartment_id', $apartmentId)
            ->where('renter_id', $user->id)
            ->where('status', 'completed')
            ->where('end_date', '<', now())
            ->exists();

        if (!$hasCompletedBooking) {
            return response()->json([
                'message' => 'You can only rate apartments after completing your booking'
            ], 403);
        }

        // Check if user already rated this apartment
        $existingRating = Rating::where('apartment_id', $apartmentId)
            ->where('renter_id', $user->id)
            ->first();

        if ($existingRating) {
            return response()->json([
                'message' => 'You have already rated this apartment'
            ], 409);
        }

        try {
            $rating = Rating::create([
                'apartment_id' => $apartmentId,
                'renter_id' => $user->id,
                'rating' => $request->rating,
                'comment' => $request->comment,
            ]);

            // Update apartment's average rating
            $this->updateApartmentAverageRating($apartmentId);

            return response()->json([
                'message' => 'Rating submitted successfully',
                'rating' => $rating,
                'average_rating' => $this->getApartmentAverageRating($apartmentId),
                'ratings_count' => Rating::where('apartment_id', $apartmentId)->count(),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to submit rating',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function checkRatingEligibility($apartmentId)
    {
        $user = Auth::user();

        // Check if user has any booking for this apartment
        $booking = Booking::where('apartment_id', $apartmentId)
            ->where('renter_id', $user->id)
            ->first();

        if (!$booking) {
            return response()->json([
                'data' => [
                    'can_rate' => false,
                    'has_booking' => false,
                    'already_rated' => false,
                    'reason' => 'You must book this apartment first'
                ]
            ]);
        }

        // Check if booking is completed
        $isCompleted = $booking->status === 'completed' && $booking->end_date < now();

        if (!$isCompleted) {
            return response()->json([
                'data' => [
                    'can_rate' => false,
                    'has_booking' => true,
                    'already_rated' => false,
                    'reason' => 'You can only rate after the booking ends'
                ]
            ]);
        }

        // Check if already rated
        $alreadyRated = Rating::where('apartment_id', $apartmentId)
            ->where('renter_id', $user->id)
            ->exists();

        if ($alreadyRated) {
            return response()->json([
                'data' => [
                    'can_rate' => false,
                    'has_booking' => true,
                    'already_rated' => true,
                    'reason' => 'You have already rated this apartment'
                ]
            ]);
        }

        return response()->json([
            'data' => [
                'can_rate' => true,
                'has_booking' => true,
                'already_rated' => false,
                'reason' => null
            ]
        ]);
    }

    public function getAverageRating($apartmentId)
    {
        $averageRating = $this->getApartmentAverageRating($apartmentId);
        $ratingsCount = Rating::where('apartment_id', $apartmentId)->count();

        return response()->json([
            'data' => [
                'average_rating' => $averageRating,
                'ratings_count' => $ratingsCount,
                'rating_text' => $ratingsCount > 0
                    ? number_format($averageRating, 1) . ' ⭐ (' . $ratingsCount . ' rating' . ($ratingsCount != 1 ? 's' : '') . ')'
                    : 'No ratings yet'
            ]
        ]);
    }

    public function getApartmentRatings(Request $request, $apartmentId)
    {
        $perPage = 10;
        $page = $request->get('page', 1);

        $ratings = Rating::with(['renter:id,first_name,last_name'])
            ->where('apartment_id', $apartmentId)
            ->orderBy('created_at', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);

        $summary = $this->getRatingSummary($apartmentId);

        return response()->json([
            'ratings' => [
                'data' => $ratings->items(),
                'current_page' => $ratings->currentPage(),
                'last_page' => $ratings->lastPage(),
                'total' => $ratings->total(),
            ],
            'apartment' => Apartment::find($apartmentId),
            'summary' => $summary,
        ]);
    }

    public function deleteRating($ratingId)
    {
        $user = Auth::user();

        $rating = Rating::where('id', $ratingId)
            ->where('renter_id', $user->id)
            ->first();

        if (!$rating) {
            return response()->json([
                'message' => 'Rating not found or you do not have permission to delete it'
            ], 404);
        }

        $apartmentId = $rating->apartment_id;

        $rating->delete();

        // Update apartment's average rating
        $this->updateApartmentAverageRating($apartmentId);

        return response()->json([
            'message' => 'Rating deleted successfully',
            'average_rating' => $this->getApartmentAverageRating($apartmentId),
            'ratings_count' => Rating::where('apartment_id', $apartmentId)->count(),
        ]);
    }

    private function getApartmentAverageRating($apartmentId)
    {
        return Rating::where('apartment_id', $apartmentId)
            ->avg('rating') ?? 0;
    }

    private function updateApartmentAverageRating($apartmentId)
    {
        $averageRating = $this->getApartmentAverageRating($apartmentId);

        Apartment::where('id', $apartmentId)->update([
            'average_rating' => $averageRating,
            'ratings_count' => Rating::where('apartment_id', $apartmentId)->count(),
        ]);
    }

    private function getRatingSummary($apartmentId)
    {
        $ratings = Rating::where('apartment_id', $apartmentId)
            ->select('rating', DB::raw('count(*) as count'))
            ->groupBy('rating')
            ->get()
            ->keyBy('rating');

        return [
            '5_stars' => $ratings->get(5)?->count ?? 0,
            '4_stars' => $ratings->get(4)?->count ?? 0,
            '3_stars' => $ratings->get(3)?->count ?? 0,
            '2_stars' => $ratings->get(2)?->count ?? 0,
            '1_stars' => $ratings->get(1)?->count ?? 0,
        ];
    }
}
```

## Update Booking Completion Logic
Make sure bookings are marked as 'completed' when end_date passes. You can add this to a scheduled job or check it when needed.

## Testing the Implementation
1. Run the migration: `php artisan migrate`
2. Test the endpoints with Postman or your Flutter app
3. Make sure authentication is working properly

## Important Notes
- The `checkRatingEligibility` method checks for completed bookings (status = 'completed' AND end_date < now())
- Users can only rate once per apartment
- Ratings are 1-5 stars with optional comments
- The system updates apartment average ratings automatically
