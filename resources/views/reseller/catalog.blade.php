@extends('layouts.app')

@section('title', 'Catalogo Esperienze - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Catalogo Esperienze</h1>
    </div>

    <!-- Filtri -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
        <form action="{{ route('reseller.catalog') }}" method="GET" class="flex gap-4">
            <input type="text" name="search" value="{{ request('search') }}" 
                   placeholder="Cerca esperienze..." 
                   class="flex-1 border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
            <button type="submit" 
                    class="bg-orange-600 text-white px-6 py-2 rounded-md hover:bg-orange-700 font-medium">
                Cerca
            </button>
        </form>
    </div>

    <!-- Lista Esperienze -->
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
                            <span class="text-2xl font-bold text-gray-900">€{{ number_format($experience->price_adult ?? 0, 2) }}</span>
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
                <p class="text-gray-500">Nessuna esperienza disponibile nel catalogo.</p>
            </div>
        @endforelse
    </div>

    <!-- Paginazione -->
    <div class="mt-6">
        {{ $experiences->links() }}
    </div>
</div>
@endsection

