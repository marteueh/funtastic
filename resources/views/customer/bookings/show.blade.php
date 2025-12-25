@extends('layouts.app')

@section('title', 'Dettaglio Prenotazione - FUNTASTING')

@section('content')
<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Dettaglio Prenotazione</h1>

    <div class="bg-white rounded-lg shadow p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">{{ $booking->experience->title }}</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <h3 class="font-semibold text-gray-700 mb-2">Informazioni Prenotazione</h3>
                <div class="space-y-2 text-sm">
                    <p><strong>Codice:</strong> {{ $booking->booking_code }}</p>
                    <p><strong>Data:</strong> {{ \Carbon\Carbon::parse($booking->experience_date)->format('d/m/Y') }}</p>
                    @if($booking->experience_time)
                        <p><strong>Ora:</strong> {{ \Carbon\Carbon::parse($booking->experience_time)->format('H:i') }}</p>
                    @endif
                    <p><strong>Stato:</strong> 
                        <span class="font-medium {{ $booking->status === 'confirmed' ? 'text-green-600' : 
                           ($booking->status === 'cancelled' ? 'text-red-600' : 'text-yellow-600') }}">
                            {{ ucfirst($booking->status) }}
                        </span>
                    </p>
                </div>
            </div>

            <div>
                <h3 class="font-semibold text-gray-700 mb-2">Partecipanti</h3>
                <div class="space-y-2 text-sm">
                    <p><strong>Adulti:</strong> {{ $booking->adults }}</p>
                    @if($booking->children > 0)
                        <p><strong>Bambini:</strong> {{ $booking->children }}</p>
                    @endif
                    @if($booking->seniors > 0)
                        <p><strong>Senior:</strong> {{ $booking->seniors }}</p>
                    @endif
                    <p><strong>Totale:</strong> {{ $booking->total_participants }} persone</p>
                </div>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6 mb-6">
        <h3 class="font-semibold text-gray-700 mb-4">Riepilogo Pagamento</h3>
        <div class="space-y-2">
            <div class="flex justify-between">
                <span>Totale</span>
                <span class="font-bold">€{{ number_format($booking->total_amount, 2) }}</span>
            </div>
            @if($booking->discount_amount > 0)
                <div class="flex justify-between text-green-600">
                    <span>Sconto</span>
                    <span>-€{{ number_format($booking->discount_amount, 2) }}</span>
                </div>
            @endif
            <div class="flex justify-between text-lg font-bold pt-2 border-t">
                <span>Totale Pagato</span>
                <span>€{{ number_format($booking->total_amount - $booking->discount_amount, 2) }}</span>
            </div>
            <p class="text-sm text-gray-600 mt-2">
                <strong>Metodo:</strong> {{ ucfirst($booking->payment_method ?? 'Non specificato') }}
            </p>
            <p class="text-sm text-gray-600">
                <strong>Stato Pagamento:</strong> 
                <span class="font-medium {{ $booking->payment_status === 'paid' ? 'text-green-600' : 'text-yellow-600' }}">
                    {{ ucfirst($booking->payment_status) }}
                </span>
            </p>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="font-semibold text-gray-700 mb-4">Punto di Ritrovo</h3>
        <p class="text-gray-600">{{ $booking->experience->meeting_point ?? 'Da confermare' }}</p>
    </div>

    <div class="mt-6">
        <a href="{{ route('customer.bookings') }}" 
           class="text-orange-600 hover:text-orange-700 font-medium">
            ← Torna alle prenotazioni
        </a>
    </div>
</div>
@endsection

