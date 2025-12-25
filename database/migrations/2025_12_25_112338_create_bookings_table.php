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
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->string('booking_code')->unique(); // Codice univoco prenotazione
            $table->foreignId('experience_id')->constrained()->onDelete('restrict');
            $table->foreignId('customer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('reseller_id')->nullable()->constrained('users')->onDelete('set null'); // Se prenotato da hotel
            
            // Dati prenotazione
            $table->date('experience_date');
            $table->time('experience_time')->nullable();
            $table->integer('adults')->default(1);
            $table->integer('children')->default(0);
            $table->integer('seniors')->default(0);
            $table->integer('total_participants');
            
            // Pricing
            $table->decimal('total_amount', 10, 2);
            $table->decimal('commission_amount', 10, 2)->default(0); // Commissione per reseller
            $table->string('currency')->default('EUR');
            
            // Pagamento
            $table->enum('payment_status', ['pending', 'paid', 'refunded', 'cancelled'])->default('pending');
            $table->enum('payment_method', ['cash', 'card', 'bancomat', 'paypal', 'klarna', 'other'])->nullable();
            $table->string('payment_reference')->nullable();
            
            // Voucher e sconti
            $table->string('voucher_code')->nullable();
            $table->decimal('discount_amount', 10, 2)->default(0);
            
            // Status
            $table->enum('status', ['pending', 'confirmed', 'completed', 'cancelled', 'no_show'])->default('pending');
            $table->boolean('checked_in')->default(false);
            $table->timestamp('checked_in_at')->nullable();
            $table->string('qr_code')->unique()->nullable();
            
            // Note
            $table->text('customer_notes')->nullable();
            $table->text('vendor_notes')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
