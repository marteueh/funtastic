<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Reseller extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'company_name', 'business_type', 'vat_number', 'phone',
        'email', 'address', 'total_commissions', 'pending_commissions',
        'curated_experiences', 'widget_token', 'qr_code_path'
    ];

    protected $casts = [
        'curated_experiences' => 'array',
        'total_commissions' => 'decimal:2',
        'pending_commissions' => 'decimal:2',
    ];

    // Relazioni
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'reseller_id', 'user_id');
    }
}
