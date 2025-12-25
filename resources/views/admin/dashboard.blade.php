@extends('layouts.app')

@section('title', 'Dashboard Admin - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard Amministratore</h1>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Utenti Totali</h3>
            <p class="text-3xl font-bold text-orange-600">{{ \App\Models\User::count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Fornitori</h3>
            <p class="text-3xl font-bold text-gray-900">{{ \App\Models\Vendor::count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Esperienze</h3>
            <p class="text-3xl font-bold text-gray-900">{{ \App\Models\Experience::count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Prenotazioni</h3>
            <p class="text-3xl font-bold text-gray-900">{{ \App\Models\Booking::count() }}</p>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">Fornitori da Approvare</h2>
            </div>
            <div class="p-6">
                <a href="{{ route('admin.vendors') }}" class="text-orange-600 hover:text-orange-700 font-medium">
                    Gestisci Fornitori →
                </a>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow">
            <div class="p-6 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">Esperienze</h2>
            </div>
            <div class="p-6">
                <a href="{{ route('admin.experiences') }}" class="text-orange-600 hover:text-orange-700 font-medium">
                    Gestisci Esperienze →
                </a>
            </div>
        </div>
    </div>
</div>
@endsection

