<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'slug', 'description', 'icon', 'tags', 'order', 'is_active'
    ];

    protected $casts = [
        'tags' => 'array',
        'is_active' => 'boolean',
    ];

    public function experiences()
    {
        return $this->hasMany(Experience::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
