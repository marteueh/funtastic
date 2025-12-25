@extends('layouts.app')

@section('title', $experience->title . ' - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Main Content -->
        <div class="lg:col-span-2">
            <!-- Image Gallery -->
            <div class="mb-6">
                <div class="h-96 bg-gray-200 rounded-lg flex items-center justify-center">
                    <span class="text-gray-400">Immagine Esperienza</span>
                </div>
            </div>

            <!-- Title and Basic Info -->
            <div class="mb-6">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ $experience->title }}</h1>
                <div class="flex items-center space-x-4 text-sm text-gray-600">
                    <span>{{ $experience->category->name ?? 'Categoria' }}</span>
                    <span>•</span>
                    <span>{{ is_array($experience->destinations) ? implode(', ', $experience->destinations) : 'Marche' }}</span>
                </div>
            </div>

            <!-- Description -->
            <div class="mb-6">
                <h2 class="text-xl font-semibold mb-3">Descrizione</h2>
                <p class="text-gray-700 leading-relaxed">{{ $experience->long_description ?? $experience->short_description }}</p>
            </div>

            <!-- Details -->
            <div class="mb-6">
                <h2 class="text-xl font-semibold mb-3">Dettagli</h2>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <span class="text-sm font-medium text-gray-600">Durata:</span>
                        <p class="text-gray-900">{{ $experience->duration ?? 'N/A' }}</p>
                    </div>
                    <div>
                        <span class="text-sm font-medium text-gray-600">Orario:</span>
                        <p class="text-gray-900">{{ $experience->start_time_classification ?? 'N/A' }}</p>
                    </div>
                    <div>
                        <span class="text-sm font-medium text-gray-600">Partecipanti:</span>
                        <p class="text-gray-900">{{ $experience->min_participants ?? 1 }} - {{ $experience->max_participants ?? 'N/A' }}</p>
                    </div>
                    <div>
                        <span class="text-sm font-medium text-gray-600">Lingue:</span>
                        <p class="text-gray-900">{{ is_array($experience->languages_supported) ? implode(', ', $experience->languages_supported) : 'Italiano' }}</p>
                    </div>
                </div>
            </div>

            <!-- Reviews -->
            <div class="mb-6">
                <h2 class="text-xl font-semibold mb-3">Recensioni</h2>
                <p class="text-gray-600">Nessuna recensione ancora.</p>
            </div>
        </div>

        <!-- Booking Sidebar -->
        <div class="lg:col-span-1">
            <div class="bg-white rounded-lg shadow-lg p-6 sticky top-4">
                <div class="mb-4">
                    <div class="text-3xl font-bold text-gray-900 mb-2">
                        €{{ number_format($experience->price_adult ?? 0, 2) }}
                        <span class="text-lg font-normal text-gray-600">/persona</span>
                    </div>
                </div>

                @auth
                    @if(auth()->user()->role === 'customer')
                        <form action="{{ route('customer.bookings.store') }}" method="POST" class="space-y-4">
                            @csrf
                            <input type="hidden" name="experience_id" value="{{ $experience->id }}">
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Data</label>
                                <input type="date" name="booking_date" required 
                                       min="{{ date('Y-m-d') }}"
                                       class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Adulti</label>
                                <input type="number" name="num_adults" value="1" min="1" required 
                                       class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Bambini</label>
                                <input type="number" name="num_children" value="0" min="0" 
                                       class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            </div>

                            <button type="submit" 
                                    class="w-full bg-orange-600 text-white px-4 py-3 rounded-md hover:bg-orange-700 font-medium">
                                Prenota Ora
                            </button>
                        </form>
                    @endif
                @else
                    <div class="text-center">
                        <p class="text-gray-600 mb-4">Accedi per prenotare</p>
                        <a href="{{ route('login') }}" 
                           class="block w-full bg-orange-600 text-white px-4 py-3 rounded-md hover:bg-orange-700 font-medium text-center">
                            Accedi
                        </a>
                    </div>
                @endauth
            </div>
        </div>
    </div>
</div>
@endsection

