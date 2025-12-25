@extends('layouts.app')

@section('title', 'Dashboard Cliente - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Benvenuto, {{ auth()->user()->name }}</h1>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Prenotazioni Attive</h3>
            <p class="text-3xl font-bold text-orange-600">{{ auth()->user()->bookings()->where('status', 'confirmed')->count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Prenotazioni Totali</h3>
            <p class="text-3xl font-bold text-gray-900">{{ auth()->user()->bookings()->count() }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Esperienze Salvate</h3>
            <p class="text-3xl font-bold text-gray-900">0</p>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-semibold text-gray-900">Le tue prenotazioni</h2>
        </div>
        <div class="p-6">
            @forelse(auth()->user()->bookings()->latest()->take(5)->get() as $booking)
                <div class="border-b border-gray-200 py-4">
                    <div class="flex justify-between items-start">
                        <div>
                            <h3 class="font-semibold text-gray-900">{{ $booking->experience->title }}</h3>
                            <p class="text-sm text-gray-600">{{ $booking->booking_date_time->format('d/m/Y H:i') }}</p>
                            <p class="text-sm text-gray-600">Stato: 
                                <span class="font-medium {{ $booking->status === 'confirmed' ? 'text-green-600' : 'text-yellow-600' }}">
                                    {{ ucfirst($booking->status) }}
                                </span>
                            </p>
                        </div>
                        <div class="text-right">
                            <p class="text-lg font-bold text-gray-900">€{{ number_format($booking->total_price, 2) }}</p>
                            <a href="{{ route('customer.bookings.show', $booking) }}" 
                               class="text-sm text-orange-600 hover:text-orange-700">Dettagli</a>
                        </div>
                    </div>
                </div>
            @empty
                <p class="text-gray-600">Nessuna prenotazione ancora.</p>
            @endforelse
        </div>
    </div>
</div>
@endsection

