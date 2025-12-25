@extends('layouts.app')

@section('title', 'Dashboard Fornitore - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Dashboard Fornitore</h1>
        <a href="{{ route('vendor.experiences.create') }}" 
           class="bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700 font-medium">
            Nuova Esperienza
        </a>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Esperienze Attive</h3>
            <p class="text-3xl font-bold text-orange-600">{{ auth()->user()->experiences()->count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Prenotazioni Oggi</h3>
            <p class="text-3xl font-bold text-gray-900">{{ auth()->user()->experiences()->withCount('bookings')->get()->sum('bookings_count') }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Fatturato Mensile</h3>
            <p class="text-3xl font-bold text-gray-900">€0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Valutazione Media</h3>
            <p class="text-3xl font-bold text-gray-900">-</p>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">Le tue esperienze</h2>
            </div>
            <div class="p-6">
                @forelse(auth()->user()->experiences()->latest()->take(5)->get() as $experience)
                    <div class="border-b border-gray-200 py-4 last:border-0">
                        <div class="flex justify-between items-start">
                            <div>
                                <h3 class="font-semibold text-gray-900">{{ $experience->title }}</h3>
                                <p class="text-sm text-gray-600">{{ $experience->short_description }}</p>
                            </div>
                            <a href="{{ route('vendor.experiences.edit', $experience) }}" 
                               class="text-sm text-orange-600 hover:text-orange-700">Modifica</a>
                        </div>
                    </div>
                @empty
                    <p class="text-gray-600">Nessuna esperienza ancora.</p>
                @endforelse
                <div class="mt-4">
                    <a href="{{ route('vendor.experiences.index') }}" 
                       class="text-orange-600 hover:text-orange-700 font-medium">Vedi tutte →</a>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">Prenotazioni Recenti</h2>
            </div>
            <div class="p-6">
                <p class="text-gray-600">Nessuna prenotazione recente.</p>
            </div>
        </div>
    </div>
</div>
@endsection

