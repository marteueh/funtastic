<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Vendor extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'company_name', 'vat_number', 'fiscal_code', 'legal_address',
        'phone', 'email', 'visura_camerale_path', 'id_document_path', 'kyc_status',
        'about_us', 'logo_path', 'social_links', 'rating', 'iban', 'bank_name', 'account_holder'
    ];

    protected $casts = [
        'social_links' => 'array',
        'rating' => 'decimal:2',
    ];

    // Relazioni
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function experiences()
    {
        return $this->hasMany(Experience::class, 'vendor_id', 'user_id');
    }

    // Scopes
    public function scopeApproved($query)
    {
        return $query->where('kyc_status', 'approved');
    }
}
