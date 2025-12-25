<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'experience_id', 'booking_id', 'user_id', 'rating', 'comment',
        'is_verified', 'is_visible'
    ];

    protected $casts = [
        'is_verified' => 'boolean',
        'is_visible' => 'boolean',
    ];

    // Relazioni
    public function experience()
    {
        return $this->belongsTo(Experience::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopeVisible($query)
    {
        return $query->where('is_visible', true);
    }

    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }
}
