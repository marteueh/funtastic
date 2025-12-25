<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Experience extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'vendor_id', 'category_id', 'title', 'short_description', 'full_description',
        'languages', 'has_lis', 'has_braille', 'start_time_period', 'duration',
        'location_type', 'province', 'meeting_point', 'latitude', 'longitude',
        'parking_info', 'what_to_bring', 'user_types', 'age_groups', 'group_types',
        'disabilities', 'pets_allowed', 'has_offer', 'free_cancellation', 'is_new',
        'few_spots_left', 'tour_type', 'sustainability_score', 'small_association',
        'price_adult', 'price_child', 'price_senior', 'price_group', 'season',
        'available_from', 'available_to', 'min_participants', 'max_participants',
        'cutoff_hours', 'cancellation_policy', 'weather_cancellation', 'indoor_alternative',
        'images', 'video_url', 'status', 'views', 'rating', 'reviews_count'
    ];

    protected $casts = [
        'languages' => 'array',
        'user_types' => 'array',
        'age_groups' => 'array',
        'group_types' => 'array',
        'disabilities' => 'array',
        'images' => 'array',
        'has_lis' => 'boolean',
        'has_braille' => 'boolean',
        'pets_allowed' => 'boolean',
        'has_offer' => 'boolean',
        'free_cancellation' => 'boolean',
        'is_new' => 'boolean',
        'few_spots_left' => 'boolean',
        'small_association' => 'boolean',
        'weather_cancellation' => 'boolean',
        'indoor_alternative' => 'boolean',
        'price_adult' => 'decimal:2',
        'price_child' => 'decimal:2',
        'price_senior' => 'decimal:2',
        'price_group' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'rating' => 'decimal:2',
        'available_from' => 'date',
        'available_to' => 'date',
    ];

    // Relazioni
    public function vendor()
    {
        return $this->belongsTo(User::class, 'vendor_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // Scopes per filtri
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByProvince($query, $province)
    {
        return $query->where('province', $province);
    }

    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    public function scopeByPriceRange($query, $min, $max)
    {
        return $query->whereBetween('price_adult', [$min, $max]);
    }

    public function scopeByRating($query, $minRating)
    {
        return $query->where('rating', '>=', $minRating);
    }
}
