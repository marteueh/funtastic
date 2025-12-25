@extends('layouts.app')

@section('title', 'Risultati Ricerca - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-2xl font-bold text-gray-900 mb-6">Risultati Ricerca</h1>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Filtri Sidebar -->
        <div class="md:col-span-1">
            <div class="bg-white rounded-lg shadow p-6 sticky top-4">
                <h2 class="text-lg font-semibold mb-4">Filtri</h2>
                <form action="{{ route('search') }}" method="GET" class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Categoria</label>
                        <select name="category_id" class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                            <option value="">Tutte</option>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}" {{ request('category_id') == $category->id ? 'selected' : '' }}>
                                    {{ $category->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Prezzo Max</label>
                        <input type="number" name="max_price" placeholder="€" 
                               value="{{ request('max_price') }}"
                               class="w-full border-gray-300 rounded-md shadow-sm focus:border-orange-500 focus:ring-orange-500">
                    </div>
                    <button type="submit" 
                            class="w-full bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700 font-medium">
                        Applica Filtri
                    </button>
                </form>
            </div>
        </div>

        <!-- Risultati -->
        <div class="md:col-span-2">
            <div class="mb-4">
                <p class="text-gray-600">{{ $experiences->total() }} risultati trovati</p>
            </div>
            <div class="space-y-6">
                @forelse($experiences as $experience)
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow">
                        <div class="flex">
                            <div class="h-48 w-48 bg-gray-200 flex items-center justify-center flex-shrink-0">
                                <span class="text-gray-400">Immagine</span>
                            </div>
                            <div class="p-6 flex-1">
                                <div class="flex items-start justify-between mb-2">
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
                    </div>
                @empty
                    <div class="bg-white rounded-lg shadow p-12 text-center">
                        <p class="text-gray-500 text-lg">Nessuna esperienza trovata.</p>
                    </div>
                @endforelse
            </div>

            <!-- Paginazione -->
            <div class="mt-6">
                {{ $experiences->links() }}
            </div>
        </div>
    </div>
</div>
@endsection

