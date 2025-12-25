<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Booking extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'booking_code', 'experience_id', 'customer_id', 'reseller_id',
        'experience_date', 'experience_time', 'adults', 'children', 'seniors',
        'total_participants', 'total_amount', 'commission_amount', 'currency',
        'payment_status', 'payment_method', 'payment_reference',
        'voucher_code', 'discount_amount', 'status', 'checked_in', 'checked_in_at',
        'qr_code', 'customer_notes', 'vendor_notes'
    ];

    protected $casts = [
        'experience_date' => 'date',
        'experience_time' => 'datetime',
        'checked_in' => 'boolean',
        'checked_in_at' => 'datetime',
        'total_amount' => 'decimal:2',
        'commission_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
    ];

    // Relazioni
    public function experience()
    {
        return $this->belongsTo(Experience::class);
    }

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function reseller()
    {
        return $this->belongsTo(User::class, 'reseller_id');
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }

    // Scopes
    public function scopeConfirmed($query)
    {
        return $query->where('status', 'confirmed');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }
}
