# Laravel Backend Fixes

## 1. Booking Modification Status Error

### Problem
When sending a booking modification request, the backend returns error 500 with SQLSTATE[01000]: Warning: 1265 Data truncated for column 'status' at row 1. The backend is trying to set status = 'owner_review' but the database column doesn't accept this value.

### Solution
Update the Laravel backend to use the correct status value for booking modifications.

#### Update BookingController.php (updateBooking method)

```php
public function updateBooking(Request $request, $bookingId)
{
    $booking = Booking::findOrFail($bookingId);

    // Validate that user owns this booking
    if ($booking->renter_id !== auth()->id()) {
        return response()->json(['message' => 'Unauthorized'], 403);
    }

    // Validate request
    $request->validate([
        'start_date' => 'sometimes|date|after:today',
        'end_date' => 'sometimes|date|after:start_date',
        'modification_reason' => 'nullable|string|max:500'
    ]);

    try {
        // Update booking with modification request
        $booking->update([
            'start_date' => $request->start_date ?? $booking->start_date,
            'end_date' => $request->end_date ?? $booking->end_date,
            'modification_reason' => $request->modification_reason,
            'status' => 'pending_modification', // ✅ Fix: Use correct status value
            'modification_requested_at' => now(),
        ]);

        return response()->json([
            'message' => 'Modification request sent successfully',
            'booking' => $booking
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Failed to update booking',
            'error' => $e->getMessage()
        ], 500);
    }
}
```

#### Alternative: Check Database Migration
If the status column is an enum, ensure 'pending_modification' is included in the allowed values:

```php
// In database/migrations/xxxx_create_bookings_table.php
$table->enum('status', [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
    'pending_modification', // ✅ Add this value
    'modification_approved',
    'modification_rejected'
])->default('pending');
```

## 2. Image Display Issue

### Problem
The apartment images show in details page and filtering, but not in explore (grid browsing) and posting (owner posts) because the API endpoints `showAllApartments` and `owner/apartments` are not including images in their responses.

### Solution
Modify the Laravel backend to include images in the list endpoints.

#### 1. Update ApartmentController.php

In `app/Http/Controllers/ApartmentController.php`, modify the `showAllApartments` method:

```php
public function showAllApartments(Request $request)
{
    $apartments = Apartment::with('images') // Add this to load images relationship
        ->when($request->province, function ($query) use ($request) {
            return $query->where('province', $request->province);
        })
        ->when($request->city, function ($query) use ($request) {
            return $query->where('city', $request->city);
        })
        ->get();

    return response()->json([
        'data' => ApartmentResource::collection($apartments)
    ]);
}
```

#### 2. Update OwnerController.php or wherever owner/apartments is handled

In the controller that handles `owner/apartments` endpoint:

```php
public function getOwnerApartments(Request $request)
{
    $owner = auth()->user();

    $apartments = Apartment::where('owner_id', $owner->id)
        ->with('images') // Add this to load images relationship
        ->get();

    return response()->json([
        'data' => ApartmentResource::collection($apartments)
    ]);
}
```

#### 3. Update ApartmentResource.php

In `app/Http/Resources/ApartmentResource.php`, ensure images are included:

```php
public function toArray($request)
{
    return [
        'id' => $this->id,
        'name_of_apartment' => $this->name_of_apartment,
        'province' => $this->province,
        'city' => $this->city,
        'address' => $this->address,
        'description' => $this->description,
        'daily_price' => $this->daily_price,
        'monthly_price' => $this->monthly_price,
        'yearly_price' => $this->yearly_price,
        'images' => $this->whenLoaded('images', function () {
            return $this->images->map(function ($image) {
                return [
                    'id' => $image->id,
                    'image' => asset('storage/' . $image->image_path) // Adjust path as needed
                ];
            });
        }),
        'owner_name' => $this->owner->first_name . ' ' . $this->owner->last_name,
        'owner_image' => $this->owner->profile_image ? asset('storage/' . $this->owner->profile_image) : null,
    ];
}
```

#### 4. Ensure Images Relationship in Apartment Model

In `app/Models/Apartment.php`:

```php
public function images()
{
    return $this->hasMany(ApartmentImage::class);
}
```

## Alternative Flutter-Only Solution (Not Recommended)

If you cannot modify the backend, you can modify the explore controller to fetch images separately, but this is inefficient:

```dart
// In explore_controller.dart
Future<void> fetchApartments() async {
  try {
    isLoading.value = true;

    final result = await ApiService.getApartments();

    final apartmentsWithImages = <ApartmentModel>[];
    for (var aptData in result) {
      final apt = ApartmentModel.fromJson(aptData);

      // If no images, try to fetch from details
      if (apt.images.isEmpty || apt.images.first.contains('placeholder')) {
        final details = await ApiService.getApartmentDetails(apt.id);
        if (details != null) {
          final aptWithImages = ApartmentModel.fromJson(details);
          apartmentsWithImages.add(aptWithImages);
        } else {
          apartmentsWithImages.add(apt);
        }
      } else {
        apartmentsWithImages.add(apt);
      }
    }

    apartments.assignAll(apartmentsWithImages);
  } catch (e) {
    // Handle error
  } finally {
    isLoading.value = false;
  }
}
```
