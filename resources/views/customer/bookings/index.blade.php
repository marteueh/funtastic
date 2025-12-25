@extends('layouts.app')

@section('title', 'Le Mie Prenotazioni - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Le Mie Prenotazioni</h1>

    @if(session('success'))
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            {{ session('success') }}
        </div>
    @endif

    <div class="space-y-4">
        @forelse(auth()->user()->bookings()->with('experience')->latest()->get() as $booking)
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex justify-between items-start">
                    <div class="flex-1">
                        <h3 class="text-xl font-semibold text-gray-900 mb-2">{{ $booking->experience->title }}</h3>
                        <div class="space-y-1 text-sm text-gray-600">
                            <p><strong>Data:</strong> {{ \Carbon\Carbon::parse($booking->experience_date)->format('d/m/Y') }}</p>
                            @if($booking->experience_time)
                                <p><strong>Ora:</strong> {{ \Carbon\Carbon::parse($booking->experience_time)->format('H:i') }}</p>
                            @endif
                            <p><strong>Partecipanti:</strong> {{ $booking->adults }} adulti
                                @if($booking->children > 0), {{ $booking->children }} bambini @endif
                                @if($booking->seniors > 0), {{ $booking->seniors }} senior @endif
                            </p>
                            <p><strong>Stato:</strong> 
                                <span class="font-medium {{ $booking->status === 'confirmed' ? 'text-green-600' : 
                                   ($booking->status === 'cancelled' ? 'text-red-600' : 'text-yellow-600') }}">
                                    {{ ucfirst($booking->status) }}
                                </span>
                            </p>
                        </div>
                    </div>
                    <div class="text-right ml-6">
                        <p class="text-2xl font-bold text-gray-900 mb-2">€{{ number_format($booking->total_amount, 2) }}</p>
                        <a href="{{ route('customer.bookings.show', $booking) }}" 
                           class="text-orange-600 hover:text-orange-700 text-sm font-medium">
                            Dettagli →
                        </a>
                    </div>
                </div>
            </div>
        @empty
            <div class="bg-white rounded-lg shadow p-12 text-center">
                <p class="text-gray-500 text-lg mb-4">Nessuna prenotazione ancora.</p>
                <a href="{{ route('home') }}" 
                   class="inline-block bg-orange-600 text-white px-6 py-2 rounded-md hover:bg-orange-700 font-medium">
                    Esplora Esperienze
                </a>
            </div>
        @endforelse
    </div>
</div>
@endsection

