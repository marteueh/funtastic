@extends('layouts.app')

@section('title', 'Crea Nuova Esperienza - FUNTASTING')

@section('content')
<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Crea Nuova Esperienza</h1>

    <form action="{{ route('vendor.experiences.store') }}" method="POST" class="space-y-6">
        @csrf

        <!-- Informazioni Base -->
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-xl font-semibold mb-4">Informazioni Base</h2>
            
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Titolo *</label>
                    <input type="text" name="title" value="{{ old('title') }}" required
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                    @error('title')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Categoria *</label>
                    <select name="category_id" required
                            class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                        <option value="">Seleziona categoria</option>
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>
                                {{ $category->name }}
                            </option>
                        @endforeach
                    </select>
                    @error('category_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Descrizione Breve *</label>
                    <textarea name="short_description" rows="3" required
                              class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">{{ old('short_description') }}</textarea>
                    @error('short_description')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Descrizione Completa *</label>
                    <textarea name="full_description" rows="6" required
                              class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">{{ old('full_description') }}</textarea>
                    @error('full_description')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- Dettagli Logistici -->
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-xl font-semibold mb-4">Dettagli Logistici</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Durata *</label>
                    <select name="duration" required
                            class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                        <option value="">Seleziona durata</option>
                        <option value="up_to_1h" {{ old('duration') == 'up_to_1h' ? 'selected' : '' }}>Fino a 1 ora</option>
                        <option value="1-2h" {{ old('duration') == '1-2h' ? 'selected' : '' }}>1-2 ore</option>
                        <option value="2-3h" {{ old('duration') == '2-3h' ? 'selected' : '' }}>2-3 ore</option>
                        <option value="3-5h" {{ old('duration') == '3-5h' ? 'selected' : '' }}>3-5 ore</option>
                        <option value="5h_to_1day" {{ old('duration') == '5h_to_1day' ? 'selected' : '' }}>5 ore - 1 giorno</option>
                        <option value="1-3days" {{ old('duration') == '1-3days' ? 'selected' : '' }}>1-3 giorni</option>
                        <option value="more_than_3days" {{ old('duration') == 'more_than_3days' ? 'selected' : '' }}>Più di 3 giorni</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tipo di Luogo *</label>
                    <select name="location_type" required
                            class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                        <option value="">Seleziona tipo</option>
                        <option value="borgo" {{ old('location_type') == 'borgo' ? 'selected' : '' }}>Borgo</option>
                        <option value="campagna" {{ old('location_type') == 'campagna' ? 'selected' : '' }}>Campagna</option>
                        <option value="citta" {{ old('location_type') == 'citta' ? 'selected' : '' }}>Città</option>
                        <option value="fiume_lago" {{ old('location_type') == 'fiume_lago' ? 'selected' : '' }}>Fiume/Lago</option>
                        <option value="mare" {{ old('location_type') == 'mare' ? 'selected' : '' }}>Mare</option>
                        <option value="montagna" {{ old('location_type') == 'montagna' ? 'selected' : '' }}>Montagna</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Provincia *</label>
                    <select name="province" required
                            class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                        <option value="">Seleziona provincia</option>
                        <option value="ancona" {{ old('province') == 'ancona' ? 'selected' : '' }}>Ancona</option>
                        <option value="ascoli_piceno" {{ old('province') == 'ascoli_piceno' ? 'selected' : '' }}>Ascoli Piceno</option>
                        <option value="fermo" {{ old('province') == 'fermo' ? 'selected' : '' }}>Fermo</option>
                        <option value="macerata" {{ old('province') == 'macerata' ? 'selected' : '' }}>Macerata</option>
                        <option value="pesaro_urbino" {{ old('province') == 'pesaro_urbino' ? 'selected' : '' }}>Pesaro-Urbino</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Punto di Ritrovo</label>
                    <input type="text" name="meeting_point" value="{{ old('meeting_point') }}"
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Partecipanti Min *</label>
                    <input type="number" name="min_participants" value="{{ old('min_participants', 1) }}" min="1" required
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Partecipanti Max</label>
                    <input type="number" name="max_participants" value="{{ old('max_participants') }}" min="1"
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>
            </div>
        </div>

        <!-- Prezzi -->
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-xl font-semibold mb-4">Prezzi</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Prezzo Adulto (€) *</label>
                    <input type="number" name="price_adult" value="{{ old('price_adult') }}" step="0.01" min="0" required
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Prezzo Bambino (€)</label>
                    <input type="number" name="price_child" value="{{ old('price_child') }}" step="0.01" min="0"
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Prezzo Senior (€)</label>
                    <input type="number" name="price_senior" value="{{ old('price_senior') }}" step="0.01" min="0"
                           class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                </div>
            </div>
        </div>

        <!-- Opzioni -->
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-xl font-semibold mb-4">Opzioni</h2>
            
            <div class="space-y-3">
                <div class="flex items-center">
                    <input type="checkbox" name="pets_allowed" value="1" {{ old('pets_allowed') ? 'checked' : '' }}
                           class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300 rounded">
                    <label class="ml-2 block text-sm text-gray-900">Animali ammessi</label>
                </div>

                <div class="flex items-center">
                    <input type="checkbox" name="free_cancellation" value="1" {{ old('free_cancellation') ? 'checked' : '' }}
                           class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300 rounded">
                    <label class="ml-2 block text-sm text-gray-900">Cancellazione gratuita</label>
                </div>
            </div>
        </div>

        <!-- Bottoni -->
        <div class="flex justify-end space-x-4">
            <a href="{{ route('vendor.experiences.index') }}" 
               class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                Annulla
            </a>
            <button type="submit" 
                    class="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-700 font-medium">
                Crea Esperienza
            </button>
        </div>
    </form>
</div>
@endsection

