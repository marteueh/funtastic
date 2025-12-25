@extends('layouts.app')

@section('title', 'FUNTASTING - Scopri Esperienze Uniche nelle Marche')

@section('content')
<div class="bg-gradient-to-br from-orange-50 to-orange-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Hero Section -->
        <div class="text-center mb-12">
            <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
                Scopri Esperienze Uniche nelle Marche
            </h1>
            <p class="text-xl text-gray-600 max-w-2xl mx-auto">
                Trova e prenota le migliori esperienze turistiche, enogastronomiche e sportive
            </p>
        </div>

        <!-- Search Form -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
            <form action="{{ route('search') }}" method="GET" class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Categoria</label>
                        <select name="category_id" class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            <option value="">Tutte le categorie</option>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Provincia</label>
                        <select name="province" class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            <option value="">Tutte le province</option>
                            <option value="ancona">Ancona</option>
                            <option value="ascoli_piceno">Ascoli Piceno</option>
                            <option value="fermo">Fermo</option>
                            <option value="macerata">Macerata</option>
                            <option value="pesaro_urbino">Pesaro-Urbino</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Prezzo Max</label>
                        <input type="number" name="max_price" placeholder="€" 
                               class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                    </div>
                    <div class="flex items-end">
                        <button type="submit" 
                                class="w-full bg-orange-600 text-white px-6 py-2 rounded-md hover:bg-orange-700 font-medium">
                            Cerca
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Featured Experiences -->
        <div>
            <h2 class="text-2xl font-bold text-gray-900 mb-6">Esperienze in Evidenza</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                @forelse($experiences as $experience)
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow">
                        <div class="h-48 bg-gray-200 flex items-center justify-center">
                            <span class="text-gray-400">Immagine</span>
                        </div>
                        <div class="p-6">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm text-orange-600 font-medium">
                                    {{ $experience->category->name ?? 'Categoria' }}
                                </span>
                            </div>
                            <h3 class="text-xl font-semibold text-gray-900 mb-2">
                                <a href="{{ route('experiences.show', $experience) }}" class="hover:text-orange-600">
                                    {{ $experience->title }}
                                </a>
                            </h3>
                            <p class="text-gray-600 text-sm mb-4 line-clamp-2">{{ $experience->short_description }}</p>
                            <div class="flex items-center justify-between">
                                <div>
                                    <span class="text-2xl font-bold text-gray-900">€{{ number_format($experience->price_adult, 2) }}</span>
                                    <span class="text-sm text-gray-500">/persona</span>
                                </div>
                                <a href="{{ route('experiences.show', $experience) }}" 
                                   class="bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700 text-sm font-medium">
                                    Dettagli
                                </a>
                            </div>
                        </div>
                    </div>
                @empty
                    <div class="col-span-3 text-center py-12">
                        <p class="text-gray-500">Nessuna esperienza disponibile al momento.</p>
                    </div>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection

