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
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            
            // Dati Aziendali
            $table->string('company_name');
            $table->string('vat_number')->nullable();
            $table->string('fiscal_code')->nullable();
            $table->string('legal_address')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            
            // Documenti KYC
            $table->string('visura_camerale_path')->nullable();
            $table->string('id_document_path')->nullable();
            $table->enum('kyc_status', ['pending', 'approved', 'rejected'])->default('pending');
            
            // Profilo Pubblico
            $table->text('about_us')->nullable(); // "Chi siamo"
            $table->string('logo_path')->nullable();
            $table->json('social_links')->nullable(); // {facebook, instagram, website, ecc.}
            $table->decimal('rating', 3, 2)->default(0); // Rating aggregato
            
            // Dati Finanziari
            $table->string('iban')->nullable();
            $table->string('bank_name')->nullable();
            $table->string('account_holder')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vendors');
    }
};
