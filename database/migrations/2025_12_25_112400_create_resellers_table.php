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
        Schema::create('resellers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            
            // Dati Aziendali
            $table->string('company_name');
            $table->enum('business_type', ['hotel', 'b&b', 'residence', 'camping', 'glamping', 'other'])->default('hotel');
            $table->string('vat_number')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->text('address')->nullable();
            
            // Commissioni
            $table->decimal('total_commissions', 10, 2)->default(0);
            $table->decimal('pending_commissions', 10, 2)->default(0);
            
            // Catalogo Curated
            $table->json('curated_experiences')->nullable(); // Array di experience_id preferite
            
            // Widget/White Label
            $table->string('widget_token')->unique()->nullable();
            $table->string('qr_code_path')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('resellers');
    }
};
