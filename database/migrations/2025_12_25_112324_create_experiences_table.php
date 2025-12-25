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
        Schema::create('experiences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vendor_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('category_id')->constrained()->onDelete('restrict');
            
            // Informazioni Base
            $table->string('title');
            $table->text('short_description'); // Per card
            $table->text('full_description'); // Descrizione estesa
            $table->json('languages'); // Array di lingue supportate
            $table->boolean('has_lis')->default(false); // Lingua dei Segni Italiana
            $table->boolean('has_braille')->default(false); // Braille
            
            // Dati Logistici e Temporali
            $table->enum('start_time_period', ['morning', 'afternoon', 'evening'])->nullable(); // Mattina/Pomeriggio/Sera
            $table->enum('duration', ['up_to_1h', '1-2h', '2-3h', '3-5h', '5h_to_1day', '1-3days', 'more_than_3days']);
            $table->enum('location_type', ['borgo', 'campagna', 'citta', 'fiume_lago', 'mare', 'montagna']);
            $table->enum('province', ['ascoli_piceno', 'fermo', 'macerata', 'ancona', 'pesaro_urbino']);
            $table->string('meeting_point')->nullable(); // Punto di ritrovo
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->text('parking_info')->nullable();
            $table->text('what_to_bring')->nullable();
            
            // Target e Idoneità
            $table->json('user_types'); // ['singolo', 'coppia', 'amici', 'famiglia', 'senior']
            $table->json('age_groups'); // ['0-3', '3-5', '6-10', '10-14', '14-18']
            $table->json('group_types'); // ['gruppi_15+', 'team_building', 'addio_nubilato', 'solo_adulti']
            $table->json('disabilities'); // ['visive', 'uditive', 'sensoriali', 'motorie']
            $table->boolean('pets_allowed')->default(false);
            
            // Attributi Speciali
            $table->boolean('has_offer')->default(false);
            $table->boolean('free_cancellation')->default(false);
            $table->boolean('is_new')->default(false);
            $table->boolean('few_spots_left')->default(false);
            $table->enum('tour_type', ['private', 'group', 'skip_line', 'hotel_pickup'])->nullable();
            $table->integer('sustainability_score')->nullable(); // 0-100
            $table->boolean('small_association')->default(false);
            
            // Pricing
            $table->decimal('price_adult', 10, 2);
            $table->decimal('price_child', 10, 2)->nullable();
            $table->decimal('price_senior', 10, 2)->nullable();
            $table->decimal('price_group', 10, 2)->nullable();
            $table->enum('season', ['high', 'low'])->default('high');
            
            // Booking Engine
            $table->date('available_from')->nullable();
            $table->date('available_to')->nullable();
            $table->integer('min_participants')->default(1);
            $table->integer('max_participants')->nullable();
            $table->integer('cutoff_hours')->default(24); // Ore prima per prenotare
            
            // Policy
            $table->enum('cancellation_policy', ['flexible', 'strict'])->default('flexible');
            $table->boolean('weather_cancellation')->default(false);
            $table->boolean('indoor_alternative')->default(false);
            
            // Media
            $table->json('images')->nullable(); // Array di percorsi immagini
            $table->string('video_url')->nullable(); // YouTube/Vimeo
            
            // Status
            $table->enum('status', ['draft', 'pending', 'approved', 'rejected', 'active', 'inactive'])->default('draft');
            $table->integer('views')->default(0);
            $table->decimal('rating', 3, 2)->default(0); // Media recensioni
            $table->integer('reviews_count')->default(0);
            
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('experiences');
    }
};
