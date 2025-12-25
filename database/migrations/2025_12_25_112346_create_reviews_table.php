<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('experience_id')->constrained()->onDelete('cascade');
            $table->foreignId('booking_id')->constrained()->onDelete('cascade'); // Solo recensioni verificate
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            $table->integer('rating')->unsigned(); // 1-5 stelle
            $table->text('comment')->nullable();
            $table->boolean('is_verified')->default(true); // Solo dopo aver usufruito
            $table->boolean('is_visible')->default(true);
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
